# C Interop

Use this for `@cImport`, `@cInclude`, `zig translate-c`, C ABI types, `extern struct`, opaque handles, mixed C/Zig builds, and `zig cc`.

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

## Calling C From Zig

```zig
const c = @cImport({
    @cInclude("answer.h");
});
```

Common ABI rules:

- Use `extern struct` for C-compatible layout.
- Use `opaque {}` for forward-declared C handles.
- Use `[*:0]const u8` for null-terminated C strings.
- Use `c_int`, `c_uint`, `c_long`, and related C ABI types for C signatures.
- Set `link_libc = true` when using libc or C source files.

## translate-c

`zig translate-c` is useful for inspecting how Zig sees C declarations, but do not make it a default fast validation step. On this local Zig `0.16.0` environment, trivial `translate-c` checks may take longer than normal build commands. Use it only when ABI translation is the question.

Typical focused use:

```bash
zig translate-c -I include include/library.h
```

Prefer existing headers, project bindings, and successful `zig build` output as the first validation surface.

## zig cc

Use `zig cc` when Zig is acting as a C compiler or cross C compiler:

```bash
zig cc -target x86_64-linux-musl -c src/answer.c -I include -o answer.o
```

This validates C compiler flags and target availability without requiring a full Zig build graph.
