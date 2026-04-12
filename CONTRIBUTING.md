# Contributing to Incise

Contributions welcome. Follow these guidelines.

## Setup

```bash
git clone git@github.com:MrSydar/incise.git
cd incise
source incise.plugin.zsh
```

## Code Style

Reference [AGENTS.md](./AGENTS.md) for conventions:
- 2-space indentation
- Functions: lowercase snake_case
- Private functions: `_incise_` prefix
- Comments above functions
- Keep lines under 80 chars

## Testing

Manual test (cannot automate ZLE widgets):

```bash
export INCISE_OPENAI_API_KEY="your-key"
zsh
source incise.plugin.zsh
# Press Ctrl+G, type "list files", press Tab
```

Lint check:
```bash
shellcheck incise.plugin.zsh
zsh -n incise.plugin.zsh
```

## Pull Requests

Before submitting:
- [ ] `shellcheck incise.plugin.zsh` passes
- [ ] `zsh -n incise.plugin.zsh` passes
- [ ] Tested manually with Ctrl+G
- [ ] Commit message describes "why" not "what"

Use conventional commits:
```
type: short description

Optional detailed explanation if needed.
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Issues

Use provided templates:
- **Bug:** Steps to reproduce + environment info
- **Feature:** Use case + proposed solution

Questions? Open discussion or issue.
