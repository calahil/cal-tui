#!/usr/bin/env bash
# cal-tui.sh - A minimal, reusable TUI (Text-based User Interface) Bash library
# License: MIT
# Source: https://github.com/calahil/cal-tui

### COLOR DEFINITIONS ###
RESET="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"

# Foreground colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

### GENERAL UTILITY FUNCTIONS ###
cal-tui::clear_screen() {
    printf "\033[2J\033[H"
}

cal-tui::print_header() {
    echo -e "${BOLD}${CYAN}$1${RESET}"
}

cal-tui::print_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

cal-tui::print_success() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

cal-tui::print_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

### PROGRESS BAR ###
# Usage: cal-tui::progress_bar 3 10
cal-tui::progress_bar() {
    local current=$1
    local total=$2
    local width=40

    local percent=$(( 100 * current / total ))
    local filled=$(( width * current / total ))
    local empty=$(( width - filled ))

    local bar=$(printf "%${filled}s" | tr ' ' '█')
    local space=$(printf "%${empty}s")

    printf "\r[%s%s] %d%%" "$bar" "$space" "$percent"
    if [[ "$current" -eq "$total" ]]; then
        echo ""
    fi
}

### DYNAMIC MENU ###
# Usage: cal-tui::main_menu "Title" "Option 1" "cmd1" "Option 2" "cmd2" ...
cal-tui::main_menu() {
    local title="$1"
    shift
    local -a options=()
    local -a commands=()

    while [[ $# -gt 0 ]]; do
        options+=("$1")
        shift
        commands+=("$1")
        shift
    done

    while true; do
        cal-tui::clear_screen
        cal-tui::print_header "$title"
        echo

        for index in "${!options[@]}"; do
            echo "  $((index+1))) ${options[index]}"
        done
        echo "  0) Exit"
        echo
        read -rp "Choose an option: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#options[@]} )); then
            if [[ "$choice" -eq 0 ]]; then
                echo "Goodbye!"
                exit 0
            fi
            eval "${commands[$((choice-1))]}"
            echo -e "\nPress Enter to return to menu..."
            read
        else
            cal-tui::print_error "Invalid choice. Try again."
            sleep 1
        fi
    done
}

### INPUT WITH VALIDATION ###
# Usage: input=$(cal-tui::input_prompt "Prompt text" true 'regex' 'Error message')
cal-tui::input_prompt() {
    local prompt="$1"
    local required="${2:-false}"
    local regex="${3:-}"
    local error_message="${4:-Invalid input.}"

    local input=""
    while true; do
        read -rp "$(echo -e "${CYAN}${prompt} ${RESET}")" input

        if [[ "$required" == true && -z "$input" ]]; then
            cal-tui::print_error "This field is required."
            continue
        fi

        if [[ -n "$regex" && -n "$input" ]]; then
            if ! [[ "$input" =~ $regex ]]; then
                cal-tui::print_error "$error_message"
                continue
            fi
        fi
        break
    done
    echo "$input"
}

### YES/NO CONFIRMATION ###
# Usage: if cal-tui::confirm_prompt "Are you sure?" "n"; then ...
cal-tui::confirm_prompt() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-y}"

    local default_hint
    if [[ "$default" == "y" ]]; then
        default_hint="[Y/n]"
    else
        default_hint="[y/N]"
    fi

    local response
    while true; do
        read -rp "$(echo -e "${CYAN}${prompt} ${default_hint} ${RESET}")" response
        response="${response,,}"

        if [[ -z "$response" ]]; then
            response="$default"
        fi

        case "$response" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) tui::print_error "Please answer yes or no." ;;
        esac
    done
}

