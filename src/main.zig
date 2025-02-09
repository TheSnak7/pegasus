const std = @import("std");
const protobuf = @import("protobuf");

pub fn main() !void {
    std.debug.print("Hello From Pegasus\n", .{});
    _ = protobuf;
}
