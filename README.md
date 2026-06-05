# Skills

A collection of reusable development skills. The repository currently includes a Zig development skill, and can grow to include other focused skills over time.

## Supported Tools

The skills in this repository use the standard `SKILL.md` folder format and are not tied to a single coding agent.

Verified install targets:

- Codex
- Claude Code

The skills CLI also supports installing the same skill into other local agent environments. Use the all-agent command below to install into every supported target detected on your machine.

Examples of supported targets reported by the skills CLI include Amp, Antigravity, Cline, OpenClaw, Continue, Goose, Kiro, OpenHands, Roo, Windsurf, Tabnine, Trae, and Zencoder. The exact set depends on your local skills CLI version and installed agent directories.

## Skills

- `zig-dev`: Zig development workflow for source files, build files, tests, C interop, cross-compilation, and Zig 0.16 migration.

### `zig-dev`

Use this skill when working with:

- `.zig` source files
- `build.zig` and `build.zig.zon`
- Zig tests and build failures
- C interop, `@cImport`, C ABI types, and `zig cc`
- Cross-compilation, WASM, and embedded targets
- Zig 0.15 to 0.16 migration issues

## Install `zig-dev`

```bash
npx skills add venjiang/skills --skill zig-dev
```

Install for Codex:

```bash
npx skills add venjiang/skills --skill zig-dev --agent codex
```

Install for Claude Code:

```bash
npx skills add venjiang/skills --skill zig-dev --agent claude-code
```

Install for every supported local agent detected by the skills CLI:

```bash
npx skills add venjiang/skills --skill zig-dev --agent '*'
```

## Compatibility

`zig-dev` is a plain `SKILL.md` skill with bundled Markdown references. It does not require a runtime plugin, background service, or tool-specific API.

The skill has been verified with:

- `npx skills add venjiang/skills --skill zig-dev --list`
- `npx skills use venjiang/skills@zig-dev`
- `npx skills add venjiang/skills --skill zig-dev --agent codex --copy -g -y`
- `npx skills add venjiang/skills --skill zig-dev --agent claude-code --copy -g -y`
- `npx skills add venjiang/skills --skill zig-dev --agent '*' --copy -g -y`

The all-agent installation check copied `zig-dev` into multiple supported agent skill directories. One target reported that it does not support global skill installation; this does not affect the `zig-dev` skill content or the other supported targets.

## GitHub

Repository:

```text
https://github.com/venjiang/skills
```

Expected skills.sh page after indexing:

```text
https://www.skills.sh/venjiang/skills/zig-dev
```
