const std = @import("std");

const name = "m349lcmgr";
const main_path = "src/" ++ name ++ ".zig";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(main_path),
        .target = target,
        .optimize = optimize,
        .use_lld = optimize != .Debug,
        .use_llvm = optimize != .Debug,
        .single_threaded = true,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path(main_path),
        .target = target,
        .optimize = optimize,
        .use_lld = optimize != .Debug,
        .use_llvm = optimize != .Debug,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    run_unit_tests.enableTestRunnerMode();

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
