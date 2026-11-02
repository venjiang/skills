# Zig 0.17 Porting

Use this for migrations from Zig `0.16` to `0.17` and for version-dependent failures on `0.17`.
Use the `ZIG` executable selected in `SKILL.md` for every command below.

## Establish The Version Boundary

Run `"$ZIG" version` and `"$ZIG" env` before applying a migration rule.
Read the installed `std_dir` for the exact API in that compiler release.
The [official Zig 0.17 release notes](https://ziglang.org/download/0.17.0/release-notes.html) describe the release-level changes.
For development builds, also inspect the installed compiler's documentation and diagnostics.

Keep `0.16` projects on their declared version unless the task requests an upgrade.
Do not apply `0.17` replacements throughout a repository during an unrelated fix.

## Language Changes

| Zig 0.16 pattern | Zig 0.17 action |
| --- | --- |
| `@cImport` and its C import block | Translate the header through the build graph. Read `c-interop.md`. |
| `[_]u8{0} ** count` | For repeated scalar values, use `const bytes: [count]u8 = @splat(0)`. |
| Repeating a multi-element array with `**` | Preserve the element sequence with an explicit loop or comptime construction. Scalar splatting changes that sequence. |
| `void{}` | Use `{}` where the expression requires a void value. |
| `errdefer \|err\|` | Keep plain `errdefer` for cleanup. Use `catch \|err\|` at an appropriate boundary when the error value is needed. |
| `i0` | Check the type's intent. Use `u0` when the program requires an unsigned zero-bit integer. |

`@splat` with an explicit array type also works on `0.16`.
For shared source, prefer this common spelling over a compiler-version branch.
Preserve cleanup order and returned errors when replacing an `errdefer` capture.
Do not add a catch that only returns the same error.

## Build System And Dependencies

Ordinary `root_module`, `b.createModule`, and test-step patterns remain available in both versions.
See `build-system.md` for the shared example.

Zig `0.17` removes `b.args`. Use `run_cmd.addPassthruArgs()` to forward arguments after `zig build run --`.
Keep the `b.args` form for `0.16`. Do not use the `0.17` method without checking the project's supported versions.

Zig `0.17` separates build configuration from build execution.
Inspect the selected `std.Build`, `Step`, and `LazyPath` definitions before changing custom build steps or configuration I/O.
Do not assume internal fields, custom runner interfaces, or cache files match `0.16`.
Prefer existing build steps such as `b.addSystemCommand` and `b.addWriteFiles` when they express the required work.

The built-in C translation step is deprecated in `0.17`.
It is still present in `0.17.0`. Do not report it as removed.
For new translation code, use a compatible release of the official external `translate_c` package.
Read `c-interop.md` for the package API and version selection.

Keep each dependency's declared compiler requirement and resolved hash consistent with the selected toolchain.
A package's current default branch can require a newer compiler than the project supports.

## Standard Library

Both versions use `std.Io`, explicit allocators, and module-based builds.
These shared concepts do not guarantee identical method signatures or error sets.
Check the installed declaration before replacing I/O, networking, process, or allocator APIs.

Zig `0.17` introduces `std.heap.SafeAllocator` and deprecates `std.heap.DebugAllocator` and `std.heap.Check`.
Do not replace a working allocator during unrelated maintenance.
For allocator work, check initialization, ownership, and deinitialization against the selected standard library.

## Validation

Run the relevant commands with the selected compiler:

```bash
"$ZIG" fmt --check build.zig src
"$ZIG" build
"$ZIG" build test
```

For a project that promises `0.16` and `0.17` support, run the same relevant checks with both compilers.
Use separate cache and output directories. Record compiler versions with the results.
An `ast-check` pass verifies syntax only. It does not prove build API or runtime compatibility.
