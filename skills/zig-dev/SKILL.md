---
name: zig-dev
description: Develop, debug, test, and migrate Zig 0.16 and 0.17 projects. Use for Zig source, build files, standard library APIs, C interop, and cross-compilation. Select guidance from the project's toolchain version.
---

# Zig Dev

## Select The Toolchain

- Support Zig `0.16.x` and `0.17.x`. Do not assume that the command named `zig` matches the project.
- Check the user's requested version, project version files, CI, and build scripts. Resolve conflicting requirements before version-dependent changes.
- Treat `.minimum_zig_version` as a lower bound. It does not prove compatibility with every newer compiler.
- Select the compiler through the project's existing wrapper or toolchain convention. Otherwise, set `ZIG` to the executable path.
- Run `"$ZIG" version` and `"$ZIG" env`. Use that executable for builds, tests, formatting, fetching, and version reports.
- Read API declarations from the `std_dir` and language documentation reported by the selected installation.
- If the project has no version requirement, use the verified installed compiler. State its version before version-dependent work.
- Prefer project-local `build.zig`, `build.zig.zon`, tests, and style over generic examples in this skill.
- Do not assume `zls`, `ziglint`, `zigdoc`, or other optional tools exist unless verified with `command -v`.
- In projects with `build.zig`, prefer build graph commands over single-file compiler commands.

For example, after selecting an executable available on the current machine:

```bash
ZIG=/path/to/selected/zig
"$ZIG" version
"$ZIG" env
```

The examples in the references use this `ZIG` variable. A versioned alias such as `zig17` is machine-specific.

## Route By Task

- Zig `0.16` to `0.17` migration or a `0.17` language, build, or standard library error: read `references/zig-0.17-porting.md`.
- Build system, modules, `build.zig`, `build.zig.zon`, build options, or package fetching: read `references/build-system.md`.
- Panics, error return traces, allocator leaks, crashes, native debugging, debug logging, or failing tests: read `references/debugging.md`.
- C header translation, `b.addTranslateC`, the external `translate_c` package, C ABI, or mixed C/Zig builds: read `references/c-interop.md`.
- `-Dtarget`, target triples, cross-compilation, WASM, embedded, or release artifacts: read `references/cross-compilation.md`.
- Zig `0.15` to `0.16` migration, initial `std.Io` adoption, or `@Type` removal: read `references/zig-0.16-porting.md`.
- For `@cImport` errors, use the selected version's C interop route. It is deprecated in `0.16` and removed in `0.17`.

## Default Workflow

1. Inspect existing project shape before changing code:
   - `"$ZIG" version` and `"$ZIG" env`
   - `rg -n "pub fn build|addExecutable|addModule|createModule|addTest|@cImport|addTranslateC|std\\.Io|std\\.net|@Type|fingerprint|target|optimize|build_options" build.zig build.zig.zon src`
   - `"$ZIG" build --help` when a `build.zig` exists and custom steps or options are unclear.
2. Make the smallest change matching the current project style.
3. Validate with the narrowest relevant command:
   - Full project build: `"$ZIG" build`
   - Project tests: `"$ZIG" build test`
   - Formatting: `"$ZIG" fmt --check <files>`
   - Syntax-only check: `"$ZIG" ast-check <file>`
   - Single-file tests only for self-contained files: `"$ZIG" test <file>`
4. If compiler output is large, rerun with a narrower step or add `-freference-trace=<n>` only when needed.
5. Do not delete `.zig-cache` or `zig-out` unless the user asks for cleanup or stale generated state is the specific suspected cause.

Supporting both versions in this skill does not require each project to support both versions.
For a project that promises both, run its relevant build and tests with each compiler.
Use distinct local cache and output directories when comparing versions.
Do not lower version requirements or add compatibility branches unless the task requires them.

## Coding Rules

- Pass allocators explicitly to code that allocates.
- Put `defer` or `errdefer` immediately after resource acquisition.
- Prefer `const` over `var`.
- Prefer slices over raw pointers unless ABI, ownership, or low-level layout requires pointers.
- Prefer explicit error sets for public or domain-significant APIs; avoid `anyerror` when it hides a useful contract.
- Keep tests close to implementation when that matches the project.
- For C interop, verify ABI assumptions from headers, existing bindings, or focused build output before hand-writing types.
