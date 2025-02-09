const std = @import("std");
const testing = std.testing;
const protobuf = @import("protobuf");
const genProto = @import("./gen-proto/proto_test.pb.zig");
const GenMessage = genProto.Message;
const GenPerson = genProto.Person;

test "Message-Encode-Decode" {
    const alloc = testing.allocator;
    var message = GenMessage.init(alloc);
    defer message.deinit();
    message.id = .static("7777-8888-9999");
    message.text = .static("Hello World");
    const encoded_message = try GenMessage.encode(message, alloc);
    defer alloc.free(encoded_message);
    const decoded_message = try GenMessage.decode(encoded_message, alloc);
    defer decoded_message.deinit();

    try testing.expectEqualStrings(message.text.getSlice(), decoded_message.text.getSlice());
    try testing.expectEqualStrings(message.id.getSlice(), decoded_message.id.getSlice());
}

test "Person-Encode-Decode" {
    const alloc = testing.allocator;
    var person = GenPerson.init(alloc);

    // Use dynamic strings for this test
    const buf = try alloc.alloc(u8, 200);
    defer alloc.free(buf);
    const name = try std.fmt.bufPrint(buf, "{s} {s}", .{ "John", "Doe" });

    person.id = 42;
    person.name = .move(name, alloc);
    person.email = .static("john@example.com");

    const encoded_person = try GenPerson.encode(person, alloc);
    defer alloc.free(encoded_person);
    const decoded_person = try GenPerson.decode(encoded_person, alloc);
    defer decoded_person.deinit();

    try testing.expectEqual(person.id, decoded_person.id);
    try testing.expectEqualStrings(person.name.getSlice(), decoded_person.name.getSlice());

    try testing.expectEqualStrings(person.email.getSlice(), decoded_person.email.getSlice());
}
