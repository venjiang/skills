# Cross Compilation

Use this for `-Dtarget`, target triples, `zig cc`, WASM, embedded, and multi-target release artifacts.

Use the `ZIG` executable selected in `SKILL.md` for every command below.
Check target and SDK support with that compiler. Support can differ between `0.16` and `0.17`.

## Project Builds

Prefer project build options when `build.zig` exists:

```bash
"$ZIG" build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall
"$ZIG" build -Dtarget=wasm32-wasi -Doptimize=ReleaseSmall
```

Use `"$ZIG" build --help` to check that the project exposes `-Dtarget` and `-Doptimize`.
Both versions support `b.standardTargetOptions(.{})` and `b.standardOptimizeOption(.{})`.

## Target Discovery

Use the selected compiler instead of hardcoding long target tables.
`"$ZIG" targets` can produce large output. Save its complete output to a temporary file before searching it.
Check the compiler's exit status before using the saved output.

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
"$ZIG" build-exe src/main.zig -target x86_64-linux-musl -O ReleaseSmall
"$ZIG" test src/root.zig
```

If source imports modules from `build.zig`, single-file commands can fail with `no module named ... available`.
Use `"$ZIG" build` for those modules.

## C Cross Compilation

```bash
"$ZIG" cc -target x86_64-linux-musl -O2 -o myapp main.c
"$ZIG" cc -target aarch64-linux-gnu -c src/answer.c -I include -o answer.o
```

For C interop, verify libc, sysroot, include paths, and linked libraries. Pure Zig cross-builds usually need less host setup than mixed C/Zig builds.
