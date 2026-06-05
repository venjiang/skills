# C Interop

Use this for Zig `0.16` C interop with `b.addTranslateC`, translated C modules, C ABI types, `extern struct`, opaque handles, mixed C/Zig builds, and `zig cc`.

Do not use deprecated `@cImport` / `@cInclude` for new Zig `0.16` code. Treat them as legacy patterns only when reading or minimally maintaining existing code.

Official Zig `0.16.0` guidance: release notes mark `@cImport` as deprecated and provide `b.addTranslateC` plus `@import("c")` as the build-system upgrade path: https://ziglang.org/download/0.16.0/release-notes.html#cimport-moving-to-build-system

## Zig 0.16 Build Integration

Attach C sources, include paths, and libc linkage to the root module:

```zig
const exe = b.addExecutable(.{
    .name = "my_app",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }),
});

exe.root_module.addIncludePath(b.path("include"));
exe.root_module.addCSourceFile(.{
    .file = b.path("src/answer.c"),
    .flags = &.{"-std=c11"},
});
exe.root_module.link_libc = true;
```

For multiple C files:

```zig
exe.root_module.addCSourceFiles(.{
    .files = &.{ "src/a.c", "src/b.c" },
    .flags = &.{ "-std=c11", "-Wall", "-Wextra" },
});
```

## Translating Headers For Zig

```zig
const translated = b.addTranslateC(.{
    .root_source_file = b.path("include/answer.h"),
    .target = target,
    .optimize = optimize,
});

const exe = b.addExecutable(.{
    .name = "my_app",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "c", .module = translated.createModule() },
        },
    }),
});
```

Then import translated declarations from Zig source:

```zig
const c = @import("c");
```

Common ABI rules:

- Use `extern struct` for C-compatible layout.
- Use `opaque {}` for forward-declared C handles.
- Use `[*:0]const u8` for null-terminated C strings.
- Use `c_int`, `c_uint`, `c_long`, and related C ABI types for C signatures.
- Set `link_libc = true` when using libc or C source files.

## C Enum Wrapper Mapping

`translate-c` commonly represents C enums as integer aliases and constants, not Zig domain enums. Keep those translated values at the ABI boundary and map them explicitly before they enter project logic.

Example translated shape:

```zig
pub const STATUS_OK: c_int = 0;
pub const STATUS_RETRY: c_int = 1;
pub const STATUS_FAILED: c_int = -1;
pub const enum_status = c_int;
pub const status = enum_status;
```

Preferred wrapper pattern:

```zig
const Status = enum {
    ok,
    retry,
    failed,
    unknown,
};

fn statusFromC(raw: c.status) Status {
    return switch (@as(c_int, raw)) {
        c.STATUS_OK => .ok,
        c.STATUS_RETRY => .retry,
        c.STATUS_FAILED => .failed,
        else => .unknown,
    };
}
```

Use this rule of thumb:

- Status codes and protocol codes: map to a Zig domain enum with `.unknown` or return `error.UnknownStatus`.
- Error codes: map to Zig errors or `!T` at the wrapper boundary.
- Bit flags: keep as integer flags or wrap in a dedicated flags type; do not model them as a normal Zig enum.
- ABI-only values: keep `c.*` types inside the wrapper module and do not expose them through the project API.

## translate-c

`zig translate-c` is useful for inspecting how Zig sees C declarations, but do not make it a default fast validation step. On this local Zig `0.16.0` environment, trivial `translate-c` checks may take longer than normal build commands. Use it only when ABI translation is the question.

Typical focused use:

```bash
zig translate-c -I include include/library.h
```

Prefer existing headers, project bindings, and successful `zig build` output as the first validation surface.

## Legacy @cImport

`@cImport` still exists in Zig `0.16.0`, but official release notes mark it deprecated and moving to the build system. Do not introduce it in new code. If an existing project uses `@cImport` and it builds, leave it alone unless the task is explicitly a migration or the touched code already needs C interop changes.

## zig cc

Use `zig cc` when Zig is acting as a C compiler or cross C compiler:

```bash
zig cc -target x86_64-linux-musl -c src/answer.c -I include -o answer.o
```

This validates C compiler flags and target availability without requiring a full Zig build graph.
