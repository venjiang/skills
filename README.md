# Skills

A collection of reusable development skills. The repository currently includes a Zig development skill, and can grow to include other focused skills over time.

## Current Skills

- `zig-dev`: Zig development workflow for source files, build files, tests, C interop, cross-compilation, and Zig 0.16 migration.

## Install `zig-dev`

```bash
npx skills add venjiang/skills --skill zig-dev
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

`zig-dev` is not tied to a single coding agent. It is a plain `SKILL.md` skill with bundled Markdown references, so it can be installed by tools that support the skills CLI or the same skill folder layout.

The skill has been verified with:

- `npx skills add venjiang/skills --skill zig-dev --list`
- `npx skills use venjiang/skills@zig-dev`
- `npx skills add venjiang/skills --skill zig-dev --agent '*' --copy -g -y`

The all-agent installation check copied `zig-dev` into multiple supported agent skill directories, including the Claude Code skill directory. One target reported that it does not support global skill installation; this does not affect the `zig-dev` skill content or the other supported targets.

## GitHub

Repository:

```text
https://github.com/venjiang/skills
```

Expected skills.sh page after indexing:

```text
https://www.skills.sh/venjiang/skills/zig-dev
```

## Layout

```text
skills/
  zig-dev/
    SKILL.md
    references/
      build-system.md
      c-interop.md
      cross-compilation.md
      debugging.md
      zig-0.16-porting.md
```
