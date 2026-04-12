# 🪡 Incise

> AI-powered bash command generation at your fingertips

Transform natural language into bash commands instantly with Incise - a lightweight ZSH plugin that brings AI directly to your command line. Simply press `Ctrl+G`, describe what you want, and let AI write the command for you.

## Demo

![demo](https://github.com/user-attachments/assets/9483ee31-f73e-4d3d-b899-14d88710f450)

## The Inspiration

`Ctrl+R` is invaluable for recalling commands from your history. But it only works for commands you've already typed.

Incise extends that same workflow to commands you haven't run yet. **Think of it as `Ctrl+R` for the future** - generate the command you need without leaving your terminal or breaking your flow.

`Ctrl+G` (for "**G**enerate") brings AI-powered command generation to your fingertips, right where you need it.

## When to Use Incise

Incise is **not** a replacement for comprehensive AI coding assistants like Claude Code or OpenCode. It serves a different purpose entirely.

**Incise is for those moments when you know exactly what you need to do, but can't recall the cryptic syntax.** Commands like:

- `find` - "Was it `-name` before `-type` or after? Do I need quotes around the pattern?"
- `tar` - "Is it `-xvzf` or `xvzf`? Which letter means extract again?"
- `ffmpeg` - "What's the flag order for converting video formats with specific codecs?"
- `openssl` - "How do I generate a self-signed certificate again?"
- `rsync` - "Which trailing slashes matter and what does `-a` actually include?"
- `awk` / `sed` - "What's the syntax for replacing the 3rd field in a CSV?"

Instead of context-switching to Google, AI Chat, or `man` pages, just press `Ctrl+G` and describe what you want in plain English. Incise generates the command instantly, right where you need it.

**Perfect for:** Quick command generation when you know the tool but forgot the flags.

**Not designed for:** Multi-file refactoring, debugging complex code, or extended coding sessions.

## Prerequisites

- **ZSH 5.0+** - Required for ZLE widget support
- **curl** - For API requests
- **jq** - For JSON parsing
- **shellcheck** - (Optional) For linting during development

Verify:
```bash
zsh --version  # Should be 5.0 or higher
which curl     # Should exist
which jq       # Should exist
which shellcheck  # Optional - for development
```

## Installation

### Oh My Zsh

1. Clone this repository into Oh My Zsh's custom plugins directory:
   ```bash
   git clone git@github.com:MrSydar/incise.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/incise
   ```

2. Add the plugin to your `.zshrc`:
   ```bash
   plugins=(... incise)
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone git@github.com:MrSydar/incise.git /path/to/incise
   ```

2. Source the plugin in your `.zshrc`:
   ```bash
   source /path/to/incise/incise.plugin.zsh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### zinit

Add to your `.zshrc`:
```bash
zinit light MrSydar/incise
```

### antigen

Add to your `.zshrc`:
```bash
antigen bundle MrSydar/incise
```

## Usage

### Interactive Mode (Ctrl+G)

Press `Ctrl+G` to start capture mode, type your natural language prompt (it will be underlined), then press `Tab` to generate and insert the bash command.

**Example:**
1. Press `Ctrl+G`
2. Type: `list all files modified in the last 24 hours`
3. Press `Tab`
4. Result: `find . -type f -mtime -1`

**Hotkeys:**
- `Ctrl+G` - Start capture mode
- `Tab` - Submit prompt and generate bash command
- `ESC` - Cancel capture mode
- `Backspace` - Delete characters (won't delete past capture start)

## Configuration

Incise uses [Groq](https://groq.com/) by default for fast inference, but is compatible with any OpenAI-compatible API endpoint including OpenAI, local LLMs, and other providers.

### Configuration Variables

Configure Incise by setting environment variables in your `.zshrc` **before** loading the plugin:

```bash
# API Configuration
export INCISE_OPENAI_API_KEY="your-api-key-here"        # Optional: omit for local servers without auth
export INCISE_OPENAI_API_URL="https://api.groq.com/openai"  # Default if not set
export INCISE_OPENAI_MODEL="llama-3.1-8b-instant"       # Default if not set

# AI Generation Parameters (optional - defaults shown)
export INCISE_TEMPERATURE="0.2"      # Sampling temperature (0.0-2.0)
export INCISE_MAX_TOKENS="100"       # Maximum tokens to generate
export INCISE_SEED="0"               # Random seed for reproducibility
export INCISE_TOP_P="1"              # Nucleus sampling parameter (0.0-1.0)

# System Prompt (optional - override to customize behavior)
export INCISE_SYSTEM_PROMPT="You are a bash command autocompletion assistant. Your task is to generate only a bash command on a single line. Do not include any explanations, markdown formatting, code blocks, or additional text. Output only the executable command."
```

All variables are optional except when using API providers that require authentication.

**Example `.zshrc` configuration:**

```bash
# Incise Plugin Configuration
export INCISE_OPENAI_API_KEY="gsk_xxxxxxxxxxxxxxxxxxxx"  # Your Groq API key
export INCISE_OPENAI_API_URL="https://api.groq.com/openai"
export INCISE_OPENAI_MODEL="llama-3.1-8b-instant"

# Optional: Customize AI parameters
export INCISE_TEMPERATURE="0.2"
export INCISE_MAX_TOKENS="150"

# Load Oh My Zsh
plugins=(... incise)
source $ZSH/oh-my-zsh.sh
```

### OpenAI-Compatible Endpoints

This plugin works with any OpenAI-compatible API endpoint. Examples:

**Groq (default):**
```bash
export INCISE_OPENAI_API_KEY="gsk_xxxxxxxxxxxxxxxxxxxx"
export INCISE_OPENAI_API_URL="https://api.groq.com/openai"
export INCISE_OPENAI_MODEL="llama-3.1-8b-instant"
```

**OpenAI:**
```bash
export INCISE_OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
export INCISE_OPENAI_API_URL="https://api.openai.com"
export INCISE_OPENAI_MODEL="gpt-4"
```

**Local (e.g., Ollama, LM Studio):**
```bash
# API key is optional - omit it entirely for local servers that don't require authentication
export INCISE_OPENAI_API_URL="http://localhost:11434"
export INCISE_OPENAI_MODEL="llama2"
```

### Getting API Keys

- **Groq (Free):** Get your free API key at [console.groq.com](https://console.groq.com/)
- **OpenAI:** Sign up at [platform.openai.com](https://platform.openai.com/)

## Troubleshooting

### Command Generation Fails (Nothing Happens After Tab)

If pressing `Tab` after entering your prompt doesn't generate a command, the API request may have failed. Incise saves error responses to help you diagnose the issue.

**To check what went wrong:**

1. After a failed generation, check the error response file path:
   ```bash
   echo $_incise_error_response_file
   ```

2. View the error details:
   ```bash
   cat $_incise_error_response_file
   ```

The error response typically contains details about what went wrong (invalid API key, rate limits, network issues, etc.).

## License

MIT
