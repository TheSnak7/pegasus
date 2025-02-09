const std = @import("std");
const protobuf = @import("protobuf");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const protobuf_dep = b.dependency("protobuf", .{
        .target = target,
        .optimize = optimize,
    });

    const protobuf_mod = protobuf_dep.module("protobuf");

    const zig_aio = b.dependency("zig-aio", .{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "pegasus",
        .root_module = exe_mod,
    });

    exe.root_module.addImport("protobuf", protobuf_mod);
    exe.root_module.addImport("aio", zig_aio.module("aio"));
    exe.root_module.addImport("coro", zig_aio.module("coro"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const gen_proto = b.step("gen-proto", "generates zig files from protocol buffer definitions");

    const protoc_step = protobuf.RunProtocStep.create(b, protobuf_dep.builder, target, .{
        // out directory for the generated zig files
        .destination_directory = b.path("tests/gen-proto"),
        .source_files = &.{
            "tests/proto/Person.proto",
            "tests/proto/Message.proto",
            "tests/proto/Calculator.proto",
        },
        .include_directories = &.{},
    });

    gen_proto.dependOn(&protoc_step.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const test_step = b.step("test", "Run unit tests");

    const tests = [_]*std.Build.Step.Compile{b.addTest(.{
        .name = "zig-protobuf",
        .root_source_file = b.path("tests/zig-protobuf.zig"),
        .target = target,
        .optimize = optimize,
    })};

    for (tests) |test_item| {
        test_item.root_module.addImport("protobuf", protobuf_mod);
        test_item.root_module.addImport("aio", zig_aio.module("aio"));
        test_item.root_module.addImport("coro", zig_aio.module("coro"));

        const run_main_tests = b.addRunArtifact(test_item);

        test_step.dependOn(&run_main_tests.step);
    }

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    test_step.dependOn(&run_exe_unit_tests.step);
    test_step.dependOn(&protoc_step.step);
}
