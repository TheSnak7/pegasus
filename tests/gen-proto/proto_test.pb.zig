// Code generated by protoc-gen-zig
///! package proto_test
const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const protobuf = @import("protobuf");
const ManagedString = protobuf.ManagedString;
const fd = protobuf.fd;

pub const Person = struct {
    id: i32 = 0,
    name: ManagedString = .Empty,
    email: ManagedString = .Empty,
    age: i32 = 0,

    pub const _desc_table = .{
        .id = fd(1, .{ .Varint = .Simple }),
        .name = fd(2, .String),
        .email = fd(3, .String),
        .age = fd(4, .{ .Varint = .Simple }),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};

pub const Message = struct {
    id: ManagedString = .Empty,
    text: ManagedString = .Empty,

    pub const _desc_table = .{
        .id = fd(1, .String),
        .text = fd(2, .String),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};

pub const AddRequest = struct {
    a: i64 = 0,
    b: i64 = 0,

    pub const _desc_table = .{
        .a = fd(1, .{ .Varint = .Simple }),
        .b = fd(2, .{ .Varint = .Simple }),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};

pub const AddResponse = struct {
    result: i64 = 0,

    pub const _desc_table = .{
        .result = fd(1, .{ .Varint = .Simple }),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};
