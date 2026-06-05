# Debugging

Use this for Zig panics, error return traces, allocator leaks, crashes, flaky tests, native debugger sessions, and temporary tracing.

## Workflow

1. Reproduce through the same interface the user reported:
   - Project build: `zig build`
   - Project tests: `zig build test`
   - Project run step: `zig build run -- <args>`
   - Self-contained unit: `zig test <file>`
2. Capture the exact error, panic, stack trace, or leak report.
3. Narrow the loop before changing code.
4. Add temporary tracing only at boundaries that distinguish hypotheses.
5. Remove temporary traces before final delivery.

## Useful Commands

```bash
zig build -Doptimize=Debug
zig build test
zig test src/root.zig
zig build run -- arg1 arg2
zig build -freference-trace=8
```

`Debug` is the default optimize mode for `zig build` unless the project overrides it.

## Error Return Traces

Read error return traces bottom-up to find the caller chain and top-down to find the failing operation. Use `-freference-trace=<n>` for compile-time reference traces when the default hidden references omit the useful caller.

## Logging

Use focused logging:

```zig
const log = std.log.scoped(.my_module);
log.debug("value: {d}", .{value});
std.debug.print("temporary trace: {any}\n", .{value});
```

Prefer `std.log.scoped` for durable diagnostics. Use `std.debug.print` for short-lived local traces and remove them after verification.

## Native Debugger

```bash
zig build -Doptimize=Debug
<debugger> zig-out/bin/<binary>
```

Inside the debugger:

```text
break main
run
next
step
print locals
backtrace
```

Only introduce debugger workflows when a fast command-line feedback loop is insufficient.
