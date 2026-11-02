# C Interop

Use this for Zig `0.16` and `0.17` C translation, C ABI types, mixed C/Zig builds, and `zig cc`.
Use the `ZIG` executable selected in `SKILL.md` for every command below.

## Select C Translation By Version

- In `0.16`, `@cImport` is deprecated. Prefer `b.addTranslateC` for new build-integrated translation.
- In `0.17`, `@cImport` is removed. Prefer the official external `translate_c` package for new build-integrated translation.
- The `0.17` standard library still provides `b.addTranslateC`. Its translation step is deprecated, not removed.
- Preserve working translation code unless the task requires migration. Do not add a `0.17` dependency to a `0.16` project.
- Read the pinned translator package's manifest and API before changing translation options.

Sources: [Zig 0.16 release notes](https://ziglang.org/download/0.16.0/release-notes.html#cimport-moving-to-build-system), [Zig 0.17 release notes](https://ziglang.org/download/0.17.0/release-notes.html), and [official translate-c package](https://codeberg.org/ziglang/translate-c).

## Shared C Source Integration

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

## Zig 0.16 Header Translation

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

## Zig 0.17 Header Translation

Reuse an existing compatible `translate_c` dependency. If the project needs a new translator dependency, select a release for Zig `0.17`.
The official `zig-0.17.x` branch identifies that compatibility line:

```bash
"$ZIG" fetch --save git+https://codeberg.org/ziglang/translate-c#zig-0.17.x
```

Inspect the resulting manifest and retain its resolved hash. Do not assume the package's default branch supports `0.17`.
The following fragment uses the `Translator` API from release `2.0.2`, which declares Zig `0.17.0` as its minimum version:

```zig
const Translator = @import("translate_c").Translator;

// Inside build(), after creating exe and selecting target and optimize.
const translator_package = b.dependency("translate_c", .{});
const header: Translator = .init(translator_package, .{
    .c_source_file = b.path("include/answer.h"),
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("c", header.mod);
```

Import the declarations with `@import("c")`, as in the `0.16` example.
Translator options belong to the pinned package API. They are not necessarily methods on `header.mod`.

## ABI Boundaries

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

Use the project's translation build step to inspect generated declarations.
The built-in `zig translate-c` command is a legacy interface. It can be slow on some local installations.
Check the selected compiler's help before using it. Prefer the pinned package or existing build step on `0.17`.

Typical focused use:

```bash
"$ZIG" translate-c -I include include/library.h
```

Prefer existing headers, project bindings, and successful `zig build` output as the first validation surface.

## Legacy @cImport

`@cImport` still exists in Zig `0.16`, but it is deprecated. Do not introduce it in new code.
Preserve working legacy code during unrelated maintenance. For a migration to `0.17`, replace it through the build graph.

## zig cc

Use `zig cc` when Zig is acting as a C compiler or cross C compiler:

```bash
"$ZIG" cc -target x86_64-linux-musl -c src/answer.c -I include -o answer.o
```

This validates C compiler flags and target availability without requiring a full Zig build graph.
