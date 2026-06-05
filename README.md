# Skills

A collection of reusable development skills. The repository currently includes a Zig development skill, and can grow to include other focused skills over time.

## Supported Tools

The skills in this repository use the standard `SKILL.md` folder format and are not tied to a single coding agent.

Verified install targets:

| Tool | skills CLI agent name |
| --- | --- |
| Codex | `codex` |
| Claude Code | `claude-code` |
| OpenCode | `opencode` |
| OpenClaw | `openclaw` |
| Cursor | `cursor` |
| Windsurf | `windsurf` |
| Cline | `cline` |
| Continue | `continue` |
| Goose | `goose` |
| OpenHands | `openhands` |
| Roo Code | `roo` |
| Amp | `amp` |
| AiderDesk | `aider-desk` |
| Gemini CLI | `gemini-cli` |
| Qwen Code | `qwen-code` |
| Kiro CLI | `kiro-cli` |
| GitHub Copilot | `github-copilot` |
| Tabnine CLI | `tabnine-cli` |
| Warp | `warp` |
| Zed | `zed` |
| Trae | `trae` |
| Zencoder | `zencoder` |
| Augment | `augment` |
| Antigravity | `antigravity` |

Use the all-agent command below to install into every supported target detected on your machine. The exact target set depends on your local skills CLI version and installed agent directories.

## Skills

- `zig-dev`: Zig development workflow for source files, build files, tests, C interop, cross-compilation, and Zig 0.16 migration.

### `zig-dev`

Use this skill when working with:

- `.zig` source files
- `build.zig` and `build.zig.zon`
- Zig tests and build failures
- C interop with `b.addTranslateC`, C ABI types, and `zig cc`
- Cross-compilation, WASM, and embedded targets
- Zig 0.15 to 0.16 migration issues

## Install `zig-dev`

Install the current release:

```bash
npx skills add venjiang/skills@v0.1.2 --skill zig-dev
```

Install the latest `main` branch:

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

Install for OpenCode:

```bash
npx skills add venjiang/skills --skill zig-dev --agent opencode
```

Install for OpenClaw:

```bash
npx skills add venjiang/skills --skill zig-dev --agent openclaw
```

Install for other supported tools:

```bash
npx skills add venjiang/skills --skill zig-dev --agent <agent-name>
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
- `npx skills add venjiang/skills --skill zig-dev --agent opencode --copy -g -y`
- `npx skills add venjiang/skills --skill zig-dev --agent openclaw --copy -g -y`
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

## Validation

The repository includes a Zig `0.16.0` C interop fixture at `tests/zig-0.16-c-interop-addtranslatec`. It validates the official `b.addTranslateC` plus `@import("c")` path for new Zig `0.16` C interop code.

GitHub Actions validates:

- `npx skills add . --skill zig-dev --list`
- `zig fmt --check`
- `zig ast-check build.zig`
- `zig build`
- `zig build run`
- `zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseSmall`
- `zig cc -target x86_64-linux-musl`

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE).
