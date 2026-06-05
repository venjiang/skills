# Zig 0.16 Porting

Use this for Zig `0.15` to `0.16` migrations, old stdlib API errors, `std.Io` adoption, `@Type` removal, `@cImport` migration, and `build.zig.zon` package errors.

Treat this as migration guidance, not as a substitute for local verification. Run `zig env` and inspect local stdlib source when an API detail matters.

## Local Documentation First

```bash
zig version
zig env
```

Use `zig env` to find:

- `.std_dir`: local standard library source.
- `.lib_dir`: Zig library directory.
- `.version`: active compiler version.

Prefer local source and `zig build` diagnostics over web snippets. For stdlib docs, `zig std` starts local documentation in a browser; use it only when opening a local browser is appropriate.

## Quick Migration Checks

Common Zig `0.16.0` migration signals:

- `@Type(...)` no longer works; use the specific type-creating builtins.
- `@cImport` still exists but is deprecated; new build-integrated C translation should use `b.addTranslateC`.
- `std.Io` is the main I/O interface; many old `std.io`, `std.net`, `std.posix`, time, random, and process helpers moved or changed.
- `std.process.Init` is the preferred `main` parameter for programs needing I/O, args, env, or process-lifetime allocation.
- `std.ArrayList(T)` is initialized with `.empty` or `initCapacity`, and mutating methods take an allocator.
- `build.zig.zon` uses `.name = .project_name` and requires `.fingerprint`.

## @Type Removal

Replace generic `@Type` construction with specific builtins:

```zig
const Signed32 = @Int(.signed, 32);
const Tuple = @Tuple(&.{ i32, bool });
const EnumLit = @EnumLiteral();
```

For more complex generated structs, pointers, and function types, verify the exact builtin signature against local language docs or compiler diagnostics before committing a migration.

## C Imports

For new Zig `0.16` code, prefer build-system translation:

```zig
const translated = b.addTranslateC(.{
    .root_source_file = b.path("include/library.h"),
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

Then import translated declarations:

```zig
const c = @import("c");
```

Local boundary: existing code that uses `@cImport` can remain if it builds and the task is not a migration. On this machine, `zig translate-c` can be slow even for tiny headers, so do not use it as a default fast validation command. Use it only when ABI translation is the specific question.

For C source integration and `link_libc`, see `c-interop.md`.

## std.Io And Main

Zig `0.16` introduces `std.process.Init` as the richer entrypoint for programs needing process resources:

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| std.log.info("arg: {s}", .{arg});

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout = &stdout_file_writer.interface;
    try stdout.print("hello\n", .{});
    try stdout.flush();
}
```

Keep `pub fn main() !void` for small programs that do not need I/O interfaces, process args, env, or process-lifetime allocation.

## Collections

`std.ArrayList(T)` no longer embeds an allocator by default:

```zig
const std = @import("std");

test "array list" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);

    try list.append(gpa, 'a');
    try list.appendSlice(gpa, "bc");

    const owned = try list.toOwnedSlice(gpa);
    defer gpa.free(owned);
}
```

Use `.empty` when capacity can grow later; use `try std.ArrayList(T).initCapacity(gpa, n)` when an initial capacity is known.

## build.zig.zon

Zig `0.16` package manifests use enum-literal names and fingerprints:

```zig
.{
    .name = .my_project,
    .fingerprint = 0x123456789abcdef0,
    .version = "0.1.0",
    .minimum_zig_version = "0.16.0",
    .dependencies = .{},
    .paths = .{
        "build.zig",
        "build.zig.zon",
        "src",
    },
}
```

If `fingerprint` is missing, let `zig build` generate or report the required value rather than inventing one blindly. Changing an existing fingerprint has package identity and trust implications.

Use `zig fetch --save <url>` to add package dependencies when possible. Use `zig build --fetch` to fetch dependency trees without compiling.

## Common Error Patterns

| Error or symptom | Likely cause | First fix to try |
| --- | --- | --- |
| `no field named 'root_source_file'` in build options | Old build API on `addExecutable`/`addLibrary` | Use `root_module = b.createModule(...)` |
| `expected 2 argument(s), found 1` on `ArrayList` | Missing allocator parameter | Pass allocator to `append`, `appendSlice`, `deinit`, `toOwnedSlice` |
| `no module named ... available` in single-file command | File depends on build graph imports | Use `zig build` / `zig build test` |
| `fingerprint field missing` | Old `build.zig.zon` | Add generated `.fingerprint` and use enum-literal `.name` |
| old `std.io.fixedBufferStream` usage | I/O API migration | Use `std.Io.Reader.fixed` or `std.Io.Writer.fixed` |
| old global args/env helpers | process API migration | Thread `std.process.Init` or `std.process.Init.Minimal` through entrypoint |
| `@Type` compile failures | Builtin removed | Use specific builtins such as `@Int`, `@Struct`, `@Pointer`, `@Fn`, `@Tuple` |

## Validation

- After migration: `zig fmt --check <changed files>`.
- For syntax-level migration: `zig ast-check <file>`.
- For project behavior: `zig build test`.
- For hanging tests: `zig build test --test-timeout 500ms`.
- For package manifest changes: `zig build --fetch` followed by `zig build`.
