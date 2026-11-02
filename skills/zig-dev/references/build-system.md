# Build System

Use this when editing `build.zig`, `build.zig.zon`, modules, tests, build options, package fetching, or build failures.

Use the `ZIG` executable selected in `SKILL.md` for every command below.

## Shared Zig 0.16 And 0.17 Build Shape

Both versions support `root_module` and `b.createModule`. Use this shared structure for ordinary modules, executables, and tests.
For C translation, select the version-specific API in `c-interop.md`.
For changes to custom build steps or configuration logic on `0.17`, also read `zig-0.17-porting.md`.

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
    if (@hasField(std.Build, "args")) {
        if (b.args) |args| run_cmd.addArgs(args);
    } else {
        run_cmd.addPassthruArgs();
    }
    run_step.dependOn(&run_cmd.step);

    const lib_tests = b.addTest(.{ .root_module = lib_mod });
    const exe_tests = b.addTest(.{ .root_module = exe.root_module });

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
    test_step.dependOn(&b.addRunArtifact(exe_tests).step);
}
```

Avoid defaulting to older examples that pass `.root_source_file`, `.target`, and `.optimize` directly to `b.addExecutable`; existing projects may still use older patterns, but new local guidance should follow `root_module`.

The argument-forwarding branch makes this example work with both versions.
For a single-version project, use only its matching form:

- Zig `0.16`: `if (b.args) |args| run_cmd.addArgs(args);`.
- Zig `0.17`: `run_cmd.addPassthruArgs();`.

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

Check visibility with `"$ZIG" build --help`. Project-specific options should appear as `-D<option>`.

## Package Manifest

For `build.zig.zon` in Zig `0.16` and `0.17`:

- `.minimum_zig_version` should reflect the project's real baseline.
- Preserve existing dependency pins. Select dependency releases that support the chosen compiler before adding or upgrading packages.
- Add dependencies with `"$ZIG" fetch --save <url>` when possible.
- `"$ZIG" build --fetch` fetches dependency trees without compiling the project.
- `.paths` should list only files needed for the package hash and consumption.

## Validation

- `"$ZIG" build`
- `"$ZIG" build test`
- `"$ZIG" build --help`
- `"$ZIG" build --summary all` when build graph behavior matters.
- `"$ZIG" fmt --check build.zig <changed .zig files>`
- `"$ZIG" ast-check build.zig` for syntax-level checks.
