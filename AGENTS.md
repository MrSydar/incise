# Agent Guidelines for Incise ZSH Plugin

Coding conventions and development guidelines for AI agents working on this ZSH plugin.

## Project Overview

**Type:** ZSH Plugin  
**Language:** Shell Script (Zsh)  
**Purpose:** Text generation and transformation utilities with interactive capture mode  
**Repository:** git@github.com:MrSydar/incise.git

## Build, Test & Lint Commands

### Testing
No automated testing framework exists. When adding tests:

```bash
# Recommended: Install and use shunit2 for ZSH testing
git clone https://github.com/kward/shunit2.git tests/shunit2

# Run tests (once implemented)
zsh tests/run_tests.sh
```

### Manual Testing
```bash
# Test interactive capture mode (Ctrl+G):
# 1. Set your API key: export INCISE_OPENAI_API_KEY="your-api-key"
# 2. Source the plugin: source ./incise.plugin.zsh
# 3. Press Ctrl+G to start capture mode
# 4. Type a prompt (should appear underlined), e.g., "find large files"
# 5. Press Tab to generate bash command
# 6. Press ESC to cancel if needed

# Test configuration variables
export INCISE_OPENAI_API_URL="https://api.groq.com/openai"
export INCISE_OPENAI_MODEL="llama-3.1-8b-instant"
zsh -c "source ./incise.plugin.zsh && echo 'Config loaded successfully'"
```

### Linting
```bash
# Recommended: Install shellcheck for shell script linting
shellcheck incise.plugin.zsh

# Check ZSH syntax
zsh -n incise.plugin.zsh
```

**Note:** File header uses `# shellcheck shell=bash` for shellcheck compatibility despite being ZSH script. This is intentional.

### No Build Process
Pure shell script project - no compilation or build step required.

## Code Style Guidelines

### File Structure
- **Plugin files:** Must end with `.plugin.zsh` suffix
- **Main plugin:** `incise.plugin.zsh` (entry point - currently single file)
- **File header:** Include comment with filename and brief description
- **ZLE widgets:** Prefix internal ZLE functions with `_incise_` to avoid conflicts

### Shell Script Conventions

#### Functions
```zsh
# Good: Lowercase function names, descriptive comments
# function_name - Brief description of what it does
function_name() {
  # Function body with 2-space indentation
  echo "example"
}

# Also acceptable: function keyword (less common in ZSH)
function function_name {
  echo "example"
}
```

#### Indentation & Formatting
- Use **2 spaces** for indentation (no tabs)
- One blank line between functions
- Comments above functions describing purpose
- Keep lines under 80 characters when practical

#### Naming Conventions
- **Functions:** Lowercase with underscores (snake_case): `my_function`
- **Variables:** Lowercase with underscores: `my_variable`
- **Constants:** Uppercase with underscores: `MY_CONSTANT`
- **Private functions:** Prefix with underscore: `_private_helper`
- **State variables:** Prefix with plugin name for global state: `_incise_pre_capture_buffer`

#### Variables & Quoting
```zsh
# Always quote variables: echo "$my_var"
# Use 'local' for function-scoped variables (only works inside functions)
# For top-level plugin variables, use 'typeset -g' for globals
typeset -g plugin_config="value"
local files=("file1.txt" "file2.txt")  # Arrays for lists
```

#### Comments
```zsh
# Single-line comments start with # followed by space
# Document all public functions with purpose and usage

# Multi-line descriptions:
# Line 1 of description
# Line 2 of description
my_function() {
  # Inline comments explain complex logic
  echo "result"
}
```

#### Error Handling
```zsh
# Check command success with conditionals
if ! some_command; then
  echo "Error: command failed" >&2
  return 1
fi

# Use return codes (0 = success, non-zero = failure)
validate_input() {
  [[ -n "$1" ]] || return 1
  return 0
}
```

#### Command Substitution
```zsh
# Prefer $() over backticks
result=$(command arg)

# NOT: result=`command arg`
```

### Import/Sourcing Conventions

**Current project:** Single file plugin - no sourcing needed.

**If expanding to multiple files:**
```zsh
# Source other ZSH files at top of file
# Use absolute paths relative to plugin directory

# Get plugin directory (at top level - don't use 'local')
# Using %x prompt expansion works reliably in all sourcing contexts
typeset plugin_dir="${${(%):-%x}:A:h}"

# Source dependencies
source "${plugin_dir}/lib/helper.zsh"
```

### Documentation
```zsh
# function_name - One-line description
#
# Usage: function_name arg1 [arg2]
#
# Arguments:
#   arg1 - Description of first argument
#   arg2 - (Optional) Description of second argument
#
# Returns:
#   0 on success, 1 on failure
function_name() {
  # Implementation
}
```

## Git Workflow

### Commits
- Use conventional commit format: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep first line under 72 characters
- Add detailed description after blank line if needed

```
feat: add new greeting function

Implements customizable greeting function that accepts
user name as parameter.
```

### Branch Naming
- Feature: `feature/description`
- Bug fix: `fix/description`
- Documentation: `docs/description`

## Plugin-Specific Guidelines

- Export only necessary functions (avoid polluting user environment)
- Prefix internal helper functions with underscore
- Use unique function names to avoid conflicts with other plugins
- Consider namespacing for complex plugins: `pluginname_function`
- Document all user-facing functions in README.md

## ZLE (Zsh Line Editor) Widgets

Plugin uses ZLE widgets for interactive capture mode. Follow these conventions:

### Widget Registration
```zsh
# Prefix all internal ZLE widget functions with _incise_
_incise_my_widget() {
  # Widget implementation
}

# Register widgets with zle -N
zle -N _incise_my_widget

# Override built-in widgets by creating wrapper
_incise_self_insert() {
  zle .self-insert  # Call original with dot prefix
  # Custom behavior
}
zle -N self-insert _incise_self_insert
```

### Key ZLE Variables
- `$BUFFER` - Current command line content
- `$CURSOR` - Cursor position (0-indexed)
- `region_highlight` - Array for highlighting text (format: "start end style")

### State Management
- Use `typeset -g` for global state variables shared across widgets
- Example pattern from this plugin:
  ```zsh
  typeset -g _incise_pre_capture_buffer=""
  typeset -g _incise_pre_capture_cursor=0
  typeset -g _incise_error_response_file=""
  typeset -g _incise_result=""
  ```
- State variables persist across widget calls for multi-step interactions

### Keymap Switching
- Create custom keymaps with `bindkey -N keymap_name`
- Switch keymaps with `bindkey -A source_map target_map`
- Example: `bindkey -A incise-capture main` switches main keymap to capture mode
- Restore with `bindkey -A emacs main` to exit capture mode

### Region Highlighting
- Use `region_highlight` array to visually mark text portions
- Format: `region_highlight=("start end style")`
- Example: `region_highlight=("${_incise_pre_capture_cursor} ${CURSOR} underline")`
- Clear with `region_highlight=()` when done
- Updates automatically on next redisplay

### Widget Best Practices
- Always use `zle .widget-name` to call original widget behavior
- Use `typeset -g` for global state variables shared across widgets
- Clear `region_highlight=()` when canceling operations
- Test interactive behavior manually (cannot be easily automated)
- Prevent cursor movement past logical boundaries in custom modes
