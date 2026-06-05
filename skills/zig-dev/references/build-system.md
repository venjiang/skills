# Build System

Use this when editing `build.zig`, `build.zig.zon`, modules, tests, build options, package fetching, or build failures.

## Zig 0.16 Build Shape

Prefer the Zig `0.16.0` module API. `zig init` generates `root_module` and `b.createModule` patterns.

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("my_lib", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "my_app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "my_lib", .module = lib_mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    run_step.dependOn(&run_cmd.step);

    const lib_tests = b.addTest(.{ .root_module = lib_mod });
    const exe_tests = b.addTest(.{ .root_module = exe.root_module });

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
    test_step.dependOn(&b.addRunArtifact(exe_tests).step);
}
```

Avoid defaulting to older examples that pass `.root_source_file`, `.target`, and `.optimize` directly to `b.addExecutable`; existing projects may still use older patterns, but new local guidance should follow `root_module`.

## Build Options

Use `b.option`, `b.addOptions`, and `root_module.addOptions`:

```zig
const enable_logging = b.option(bool, "logging", "Enable debug logging") orelse false;
const options = b.addOptions();
options.addOption(bool, "enable_logging", enable_logging);
exe.root_module.addOptions("build_options", options);
```

In Zig source:

```zig
const build_options = @import("build_options");
```

Validate visibility with `zig build --help`; project-specific options should appear as `-D<option>`.

## Package Manifest

For `build.zig.zon` in Zig `0.16.0`:

- `.minimum_zig_version` should reflect the project's real baseline.
- Dependencies should be added with `zig fetch --save <url>` when possible.
- `zig build --fetch` fetches dependency trees and can run without compiling.
- `.paths` should list only files needed for the package hash and consumption.

## Validation

- `zig build`
- `zig build test`
- `zig build --help`
- `zig build --summary all` when build graph behavior matters.
- `zig fmt --check build.zig <changed .zig files>`
- `zig ast-check build.zig` for syntax-level checks.
