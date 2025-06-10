#!/usr/bin/env bash
# cal-tui.sh - A minimal, reusable TUI (Text-based User Interface) Bash library
# License: MIT
# Source: https://github.com/calahil/cal-tui

### COLOR DEFINITIONS ###
RESET="\033[0m"
BOLD="\033[1m"
# UNDERLINE="\033[4m"

# Foreground colors
RED="\033[31m"
GREEN="\033[32m"
# YELLOW="\033[33m"
BLUE="\033[34m"
# MAGENTA="\033[35m"
CYAN="\033[36m"
# WHITE="\033[37m"

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

    local bar
    bar=$(printf "%${filled}s" | tr ' ' '█')
    local space
    space=$(printf "%${empty}s")

    printf "\r[%s%s] %d%%" "$bar" "$space" "$percent"
    if [[ "$current" -eq "$total" ]]; then
        echo ""
    fi
}

### DYNAMIC MENU THAT RUNS COMMANDS ###
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
        local term_width
        term_width=$(tput cols)

        # Centered header
        local header_line
        header_line="$(echo -e "${BOLD}${CYAN}${title}${RESET}")"
        local header_padding=$(( (term_width - ${#title}) / 2 ))
        printf "%*s%s\n\n" "$header_padding" "" "$header_line"

        # Print each menu option centered
        for index in "${!options[@]}"; do
            local opt_line="  $((index+1))) ${options[index]}"
            local padding=$(( (term_width - ${#opt_line}) / 2 ))
            printf "%*s%s\n" "$padding" "" "$opt_line"
        done

        # Print Exit option centered
        local exit_line="  0) Exit"
        local exit_padding=$(( (term_width - ${#exit_line}) / 2 ))
        printf "\n%*s%s\n\n" "$exit_padding" "" "$exit_line"

        # Prompt input (not centered for clarity)
        read -rp "Choose an option: " choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#options[@]} )); then
            if [[ "$choice" -eq 0 ]]; then
                echo "Goodbye!"
                exit 0
            fi
            eval "${commands[$((choice-1))]}"
            echo -e "\nPress Enter to return to menu..."
            read -r
        else
            cal-tui::print_error "Invalid choice. Try again."
            sleep 1
        fi
    done
}

# DYNAMIC MENU THAT RETURNS INDEX OF SELECTED OPTION
# Usage: index=$(cal-tui::main_menu_return_index "Title" OPTIONS)
cal-tui::main_menu_return_index() {
    local title="$1"
    shift
    local -n opts=$1

    local rows cols
    rows=$(tput lines)
    cols=$(tput cols)

    RETURNED_INDEX=-1

    while true; do
        cal-tui::clear_screen

        # Prepare menu lines (without printing yet)
        local -a menu_lines
        menu_lines+=("$(echo -e "${BOLD}${CYAN}${title}${RESET}")")
        menu_lines+=("")
        for i in "${!opts[@]}"; do
            menu_lines+=("  $((i+1))) ${opts[i]}")
        done
        menu_lines+=("  0) Cancel")
        menu_lines+=("")

        # Determine max line width (stripped of color codes for accurate spacing)
        local max_len=0
        for line in "${menu_lines[@]}"; do
            # Remove ANSI escape codes before counting length
            local stripped
            stripped=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
            local len=${#stripped}
            (( len > max_len )) && max_len=$len
        done

        # Horizontal start position so everything aligns to same column
        local start_col=$(( (cols - max_len) / 2 ))
        local start_row=$(( (rows - ${#menu_lines[@]}) / 2 ))

        # Add vertical padding
        for ((i = 0; i < start_row; i++)); do echo; done

        # Print each line at the same horizontal offset
        for line in "${menu_lines[@]}"; do
           printf "%*s%s\n" "$start_col" "" "$line"
        done

        # Input prompt aligned to the same column
        echo
        read -rp "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#opts[@]} )); then
            if [[ "$choice" -eq 0 ]]; then
                return 1
            fi
            # shellcheck disable=SC2034
            RETURNED_INDEX=$((choice - 1)) # Used externally as the choice result
            return 0
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

