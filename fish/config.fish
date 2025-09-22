# Nord Colors (from https://www.nordtheme.com/docs/colors-and-palettes)
set -g nord0 "#2e3440" # Polar Night
set -g nord1 "#3b4252" # Polar Night
set -g nord2 "#434c5e" # Polar Night
set -g nord3 "#4c566a" # Polar Night
set -g nord4 "#d8dee9" # Snow Storm
set -g nord5 "#e5e9f0" # Snow Storm
set -g nord6 "#eceff4" # Snow Storm
set -g nord7 "#8fbcbb" # Frost
set -g nord8 "#88c0d0" # Frost
set -g nord9 "#81a1c1" # Frost
set -g nord10 "#5e81ac" # Frost
set -g nord11 "#bf616a" # Aurora (Red)
set -g nord12 "#d08770" # Aurora (Orange)
set -g nord13 "#ebcb8b" # Aurora (Yellow)
set -g nord14 "#a3be8c" # Aurora (Green)
set -g nord15 "#b48ead" # Aurora (Purple)

# Base colors
set -g fish_color_normal $nord4
set -g fish_color_command $nord8 # This will apply to regular commands
set -g fish_color_redirection $nord9
set -g fish_color_error $nord11
set -g fish_color_param $nord14
set -g fish_color_quote $nord13
set -g fish_color_autosuggestion $nord3

# Specific syntax highlighting colors
set -g fish_color_comment $nord3
set -g fish_color_keyword $nord9
set -g fish_color_option $nord13
set -g fish_color_nolog $nord8
set -g fish_color_selection_background $nord2 # This is for text selection in the terminal
set -g fish_color_host $nord7
set -g fish_color_user $nord7

# Other UI elements
set -g fish_color_cwd $nord8
set -g fish_color_cwd_root $nord11
set -g fish_color_match $nord13
set -g fish_color_search_match $nord13 --background $nord0
set -g fish_color_history_current $nord13
set -g fish_color_operator $nord11
set -g fish_color_escape $nord14
set -g fish_color_valid_path $nord14
set -g fish_color_background $nord0 # Note: This sets the background for specific elements, your terminal emulator controls the overall background.

# Prompt colors (these often override some of the general colors)
set -g fish_color_status $nord11 # Color for the exit status of the last command
set -g fish_color_vcs $nord14 # Color for version control system information (e.g., Git branch)

bind \cx\040 accept-autosuggestion
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

# Alias for 'ls' with common options
alias ll "ls -laF"