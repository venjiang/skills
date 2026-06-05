# Cross Compilation

Use this for `-Dtarget`, target triples, `zig cc`, WASM, embedded, and multi-target release artifacts.

## Project Builds

Prefer project build options when `build.zig` exists:

```bash
zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall
zig build -Dtarget=wasm32-wasi -Doptimize=ReleaseSmall
```

Use `zig build --help` to confirm the project exposes `-Dtarget` and `-Doptimize`. Zig `0.16.0` templates do this through `b.standardTargetOptions(.{})` and `b.standardOptimizeOption(.{})`.

## Target Discovery

Use local Zig instead of hardcoding long target tables. `zig targets` can print tens of thousands of lines, so avoid running it unbounded when only a small fact is needed.

```bash
zig targets 2>&1 | head -c 12000
zig targets 2>&1 | rg "x86_64-linux-musl|wasm32-wasi|aarch64-macos"
```

Common examples to try only when relevant:

- `x86_64-linux-musl`
- `x86_64-linux-gnu`
- `aarch64-linux-musl`
- `aarch64-linux-gnu`
- `x86_64-windows-gnu`
- `aarch64-macos-none`
- `x86_64-macos-none`
- `wasm32-wasi`
- `wasm32-freestanding`

## Single-File Builds

Only use single-file commands when the file is self-contained and does not depend on build graph imports:

```bash
zig build-exe src/main.zig -target x86_64-linux-musl -O ReleaseSmall
zig test src/root.zig
```

If source imports modules injected by `build.zig`, single-file commands can fail with `no module named ... available`; switch back to `zig build`.

## C Cross Compilation

```bash
zig cc -target x86_64-linux-musl -O2 -o myapp main.c
zig cc -target aarch64-linux-gnu -c src/answer.c -I include -o answer.o
```

For C interop, verify libc, sysroot, include paths, and linked libraries. Pure Zig cross-builds usually need less host setup than mixed C/Zig builds.
