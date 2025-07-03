# Base colors
set -g fish_color_normal "#c4c8c5"
set -g fish_color_command "#85befd" # This will apply to regular commands
set -g fish_color_redirection "#b9b5fc"
set -g fish_color_error "#fc5ef0"
set -g fish_color_param "#86c38a"
set -g fish_color_quote "#f5ffa7"
set -g fish_color_autosuggestion "#444444"

# Specific syntax highlighting colors
set -g fish_color_comment "#444444"
set -g fish_color_keyword "#b9b5fc"
set -g fish_color_option "#ffd6b1"
set -g fish_color_nolog "#85befd"
set -g fish_color_selection_background "#444444" # This is for text selection in the terminal
set -g fish_color_host "#81a1c1"
set -g fish_color_user "#81a1c1"

# Other UI elements
set -g fish_color_cwd "#85befd"
set -g fish_color_cwd_root "#fc5ef0"
set -g fish_color_match "#ffd6b1"
set -g fish_color_search_match "#ffd6b1" --background "#2e3440"
set -g fish_color_history_current "#ffd6b1"
set -g fish_color_operator "#fc5ef0"
set -g fish_color_escape "#86c38a"
set -g fish_color_valid_path "#86c38a"
set -g fish_color_background "#2e3440" # Note: This sets the background for specific elements, your terminal emulator controls the overall background.

# Prompt colors (these often override some of the general colors)
set -g fish_color_status "#fc5ef0" # Color for the exit status of the last command
set -g fish_color_vcs "#94f936" # Color for version control system information (e.g., Git branch)

set fish_greeting ""
function fish_prompt
    set_color $fish_color_user
    echo -n (whoami)
    set_color normal
    echo -n "@"
    set_color $fish_color_host
    # Use the built-in fish variable $hostname
    echo -n $hostname
    set_color normal
    echo -n " "
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n "> "
end