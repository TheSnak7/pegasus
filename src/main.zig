const std = @import("std");
const protobuf = @import("protobuf");
const coro = @import("coro");
const aio = @import("aio");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const gpa_alloc = gpa.allocator();

    var scheduler = try coro.Scheduler.init(gpa_alloc, .{});
    defer scheduler.deinit();

    var startup: coro.ResetEvent = .{};
    _ = try scheduler.spawn(server, .{&startup}, .{});

    _ = try scheduler.run(.wait);
}

fn server(startup: *coro.ResetEvent) !void {
    var socket: std.posix.socket_t = undefined;
    try coro.io.single(.socket, .{
        .domain = std.posix.AF.INET,
        .flags = std.posix.SOCK.STREAM | std.posix.SOCK.CLOEXEC,
        .protocol = std.posix.IPPROTO.TCP,
        .out_socket = &socket,
    });

    const address = std.net.Address.initIp4(.{ 0, 0, 0, 0 }, 1327);
    try std.posix.setsockopt(socket, std.posix.SOL.SOCKET, std.posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    if (@hasDecl(std.posix.SO, "REUSEPORT")) {
        try std.posix.setsockopt(socket, std.posix.SOL.SOCKET, std.posix.SO.REUSEPORT, &std.mem.toBytes(@as(c_int, 1)));
    }
    try std.posix.bind(socket, &address.any, address.getOsSockLen());
    try std.posix.listen(socket, 128);

    startup.set();

    var client_sock: std.posix.socket_t = undefined;
    try coro.io.single(.accept, .{ .socket = socket, .out_socket = &client_sock });

    var buf: [1024]u8 = undefined;
    var len: usize = 0;
    try coro.io.multi(.{
        aio.op(.send, .{ .socket = client_sock, .buffer = "hey " }, .soft),
        aio.op(.send, .{ .socket = client_sock, .buffer = "I'm doing multiple IO ops at once " }, .soft),
        aio.op(.send, .{ .socket = client_sock, .buffer = "how cool is that?" }, .soft),
        aio.op(.recv, .{ .socket = client_sock, .buffer = &buf, .out_read = &len }, .unlinked),
    });

    std.log.warn("got reply from client: {s}", .{buf[0..len]});
    try coro.io.multi(.{
        aio.op(.send, .{ .socket = client_sock, .buffer = "ok bye" }, .soft),
        aio.op(.close_socket, .{ .socket = client_sock }, .soft),
        aio.op(.close_socket, .{ .socket = socket }, .unlinked),
    });
}
