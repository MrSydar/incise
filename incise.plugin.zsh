# shellcheck shell=bash
# incise.plugin.zsh
# Incise - Text generation and transformation utilities for ZSH

# Incise configuration variables
typeset -g _INCISE_OPENAI_API_KEY=""
typeset -g _INCISE_OPENAI_API_URL="https://api.groq.com/openai"
typeset -g _INCISE_OPENAI_MODEL="llama-3.1-8b-instant"
typeset -g _INCISE_SYSTEM_PROMPT="You are a bash command autocompletion assistant. Your task is to generate only a bash command on a single line. Do not include any explanations, markdown formatting, code blocks, or additional text. Output only the executable command."
typeset -g _INCISE_TEMPERATURE="0.2"
typeset -g _INCISE_MAX_TOKENS="100"
typeset -g _INCISE_SEED="0"
typeset -g _INCISE_TOP_P="1"

# Load configuration from environment variables if set
[[ -n "$INCISE_OPENAI_API_KEY" ]] && _INCISE_OPENAI_API_KEY="$INCISE_OPENAI_API_KEY"
[[ -n "$INCISE_OPENAI_API_URL" ]] && _INCISE_OPENAI_API_URL="$INCISE_OPENAI_API_URL"
[[ -n "$INCISE_OPENAI_MODEL" ]] && _INCISE_OPENAI_MODEL="$INCISE_OPENAI_MODEL"
[[ -n "$INCISE_SYSTEM_PROMPT" ]] && _INCISE_SYSTEM_PROMPT="$INCISE_SYSTEM_PROMPT"
[[ -n "$INCISE_TEMPERATURE" ]] && _INCISE_TEMPERATURE="$INCISE_TEMPERATURE"
[[ -n "$INCISE_MAX_TOKENS" ]] && _INCISE_MAX_TOKENS="$INCISE_MAX_TOKENS"
[[ -n "$INCISE_SEED" ]] && _INCISE_SEED="$INCISE_SEED"
[[ -n "$INCISE_TOP_P" ]] && _INCISE_TOP_P="$INCISE_TOP_P"

# _incise_generate - Internal function for generating bash command completions using AI
#
# Usage: _incise_generate "prompt"
#
# Arguments:
#   $1 - Prompt describing the bash command to generate
#
# Sets global variables:
#   _incise_result - Generated bash command from AI model (empty on error)
#   _incise_error_response_file - Path to error response file (empty on success)
_incise_generate() {
  # Escape strings for safe JSON insertion
  local escaped_prompt escaped_system_prompt
  escaped_prompt=$(printf '%s' "$1" | jq -Rs .)
  escaped_system_prompt=$(printf '%s' "$_INCISE_SYSTEM_PROMPT" | jq -Rs .)
  
  # Build auth header only if API key is provided
  local auth_header=()
  [[ -n "$_INCISE_OPENAI_API_KEY" ]] && auth_header=(--header "Authorization: Bearer $_INCISE_OPENAI_API_KEY")
  
  # Clean up previous error response file if exists
  [[ -n "$_incise_error_response_file" ]] && rm -f "$_incise_error_response_file"
  _incise_error_response_file=""
  
  # Create temp file for response body
  local temp_response
  temp_response=$(mktemp)
  
  # Make request and capture HTTP status code
  local http_status
  http_status=$(curl --location "$_INCISE_OPENAI_API_URL/v1/chat/completions" \
    --header 'Content-Type: application/json' \
    "${auth_header[@]}" \
    --data "{
      \"model\": \"$_INCISE_OPENAI_MODEL\",
      \"stream\": false,
      \"messages\": [{\"content\": $escaped_system_prompt, \"role\":\"system\"},{\"content\": $escaped_prompt, \"role\": \"user\"}],
      \"temperature\": $_INCISE_TEMPERATURE,
      \"max_tokens\": $_INCISE_MAX_TOKENS,
      \"seed\": $_INCISE_SEED,
      \"top_p\": $_INCISE_TOP_P
    }" \
    -s -w '%{http_code}' -o "$temp_response")

  # Check if status code is 2xx
  if [[ "$http_status" =~ ^2[0-9][0-9]$ ]]; then
    # Success - extract result and clean up
    _incise_result=$(jq '.choices[].message.content' -r "$temp_response")
    rm -f "$temp_response"
  else
    # Error - save temp file path for troubleshooting
    _incise_result=""
    _incise_error_response_file="$temp_response"
  fi
}

# State variables for capture mode
typeset -g _incise_pre_capture_buffer=""
typeset -g _incise_pre_capture_cursor=0
typeset -g _incise_error_response_file=""
typeset -g _incise_result=""

# _incise_start_capture - Enter capture mode and save pre-capture state
_incise_start_capture() {
  _incise_pre_capture_buffer="$BUFFER"
  _incise_pre_capture_cursor=$CURSOR

  bindkey -A incise-capture main
}

# _incise_submit_capture - Generate result and exit capture mode
_incise_submit_capture() {
  # Extract captured text from pre-capture position to current cursor
  local captured="${BUFFER:$_incise_pre_capture_cursor:$(( CURSOR - _incise_pre_capture_cursor ))}"
  
  # If no prompt was provided, just exit capture mode without generating
  if [[ -z "$captured" ]] || [[ "$captured" =~ ^[[:space:]]*$ ]]; then
    region_highlight=()
    bindkey -A emacs main
    return 0
  fi
  
  # Generate result using AI
  _incise_generate "$captured"

  # Replace captured portion with result, preserving text before and after
  BUFFER="${BUFFER[1,$_incise_pre_capture_cursor]}${_incise_result}${BUFFER[$((CURSOR+1)),-1]}"
  CURSOR=$(( _incise_pre_capture_cursor + ${#_incise_result} ))

  region_highlight=()
  bindkey -A emacs main 
}

# _incise_cancel_capture - Cancel capture mode and restore original buffer state
_incise_cancel_capture() {
  # Restore original buffer state
  BUFFER="$_incise_pre_capture_buffer"
  CURSOR=$_incise_pre_capture_cursor
  region_highlight=()

  bindkey -A emacs main 
}

# _incise_self_insert - Wrapper for self-insert with underline during capture
_incise_self_insert() {
  zle .self-insert

  # shellcheck disable=SC2034  # region_highlight is a ZSH built-in variable
  region_highlight=("${_incise_pre_capture_cursor} ${CURSOR} underline")
}

# _incise_backward_delete_char - Handle backspace during capture mode
_incise_backward_delete_char() {
  # Prevent deleting past capture start point
  if (( CURSOR > _incise_pre_capture_cursor )); then
    zle .backward-delete-char
    # shellcheck disable=SC2034  # region_highlight is a ZSH built-in variable
    region_highlight=("${_incise_pre_capture_cursor} ${CURSOR} underline")
  fi
}

# Create a new keymap for capture mode
bindkey -N incise-capture

# Register widgets
zle -N _incise_start_capture
zle -N _incise_submit_capture
zle -N _incise_cancel_capture
zle -N _incise_self_insert
zle -N _incise_backward_delete_char # temporarily disabled

# Key bindings
bindkey '^G' _incise_start_capture # Ctrl+G to start capture mode
bindkey -M incise-capture -R ' '-'~' _incise_self_insert          # Self-insert with underline in capture mode
bindkey -M incise-capture '^?' _incise_backward_delete_char # Backspace handling in capture mode
bindkey -M incise-capture '^[' _incise_cancel_capture  # ESC to cancel capture mode
bindkey -M incise-capture '^I' _incise_submit_capture    # Tab key to submit, generate and exit capture mode
