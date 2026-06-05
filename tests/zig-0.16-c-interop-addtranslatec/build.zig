const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translated = b.addTranslateC(.{
        .root_source_file = b.path("include/answer.h"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "addtranslatec_check",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "c", .module = translated.createModule() },
            },
        }),
    });

    exe.root_module.addIncludePath(b.path("include"));
    exe.root_module.addCSourceFile(.{
        .file = b.path("src/answer.c"),
        .flags = &.{"-std=c11"},
    });
    exe.root_module.link_libc = true;

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the addTranslateC fixture");
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{ .root_module = exe.root_module });
    const test_step = b.step("test", "Run fixture tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
