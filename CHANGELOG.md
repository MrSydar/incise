# Changelog

All changes tracked here. Format: [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-04-13

### Added
- Interactive capture mode (`Ctrl+G`)
- AI-powered bash command generation
- OpenAI-compatible API support (Groq, OpenAI, local LLMs)
- Configuration via environment variables
- ZLE widget integration for seamless UX
- Error response file logging for troubleshooting
- Support for Oh My Zsh, zinit, antigen, manual installation

### Features
- Underlined prompt display during capture
- Backspace protection (prevent deletion past capture start)
- ESC to cancel capture mode
- Tab to submit and generate
- Configurable temperature, max_tokens, seed, top_p parameters
- Custom system prompt override

[1.0.0]: https://github.com/MrSydar/incise/releases/tag/v1.0.0
