---
name: zig-dev
description: Zig development workflow. Use when working with `.zig`, `build.zig`, `build.zig.zon`, Zig tests, Zig build failures, Zig debugging, Zig/C interop, `zig cc`, cross-compilation, WASM, or embedded Zig targets. Assumes local Zig baseline is 0.16.0 unless the project declares another version.
---

# Zig Dev

## Baseline

- Default local Zig version is `0.16.0`; verify with `zig version` when version-specific behavior matters.
- Prefer project-local `build.zig`, `build.zig.zon`, tests, and style over this skill.
- Do not assume `zls`, `ziglint`, `zigdoc`, or other optional tools exist unless verified with `command -v`.
- In projects with `build.zig`, prefer build graph commands over single-file compiler commands.

## Route By Task

- Build system, modules, `build.zig`, `build.zig.zon`, build options, or package fetching: read `references/build-system.md`.
- Panics, error return traces, allocator leaks, crashes, native debugging, debug logging, or failing tests: read `references/debugging.md`.
- `b.addTranslateC`, C header translation, C ABI, `extern struct`, mixed C/Zig builds, or `zig cc`: read `references/c-interop.md`.
- Existing deprecated `@cImport` / `@cInclude` code or migration away from it: read `references/zig-0.16-porting.md` first, then `references/c-interop.md` if C build integration is needed.
- `-Dtarget`, target triples, cross-compilation, WASM, embedded, or release artifacts: read `references/cross-compilation.md`.
- Zig 0.15/0.16 API migration, `std.Io` changes, `@Type` removal, `@cImport` migration, `build.zig.zon` fingerprint errors, or old stdlib API errors: read `references/zig-0.16-porting.md`.

## Default Workflow

1. Inspect existing project shape before changing code:
   - `zig version`
   - `rg -n "pub fn build|addExecutable|addModule|createModule|addTest|@cImport|addTranslateC|std\\.Io|std\\.net|@Type|fingerprint|target|optimize|build_options" build.zig build.zig.zon src`
   - `zig build --help` when a `build.zig` exists and custom steps or options are unclear.
2. Make the smallest change matching the current project style.
3. Validate with the narrowest relevant command:
   - Full project build: `zig build`
   - Project tests: `zig build test`
   - Formatting: `zig fmt --check <files>`
   - Syntax-only check: `zig ast-check <file>`
   - Single-file tests only for self-contained files: `zig test <file>`
4. If compiler output is large, rerun with a narrower step or add `-freference-trace=<n>` only when needed.
5. Do not delete `.zig-cache` or `zig-out` unless the user asks for cleanup or stale generated state is the specific suspected cause.

## Coding Rules

- Pass allocators explicitly to code that allocates.
- Put `defer` or `errdefer` immediately after resource acquisition.
- Prefer `const` over `var`.
- Prefer slices over raw pointers unless ABI, ownership, or low-level layout requires pointers.
- Prefer explicit error sets for public or domain-significant APIs; avoid `anyerror` when it hides a useful contract.
- Keep tests close to implementation when that matches the project.
- For C interop, verify ABI assumptions from headers, existing bindings, or focused build output before hand-writing types.
