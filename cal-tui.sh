#!/usr/bin/env bash
# cal-tui.sh - A minimal, reusable TUI (Text-based User Interface) Bash library
# License: MIT
# Source: https://github.com/calahil/cal-tui


# === CODE DEFINITIONS ===
RESET="\033[0m"
BOLD="\033[1m"
REVERSE="\033[7m"
# UNDERLINE="\033[4m"

# === FOREGROUND COLORS ===
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

# === ICON SUPPORT ===
#
# available options  "emoji" "nerd" "text"
ICON_OVERRIDE="${CALDEV_ICON:-nerd}"

has_nerd_font() {
    fc-list | grep -qi "Nerd Font"
}
has_emoji_support() {
    [[ "$TERM" != "dumb" ]] && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" || -n "$SSH_TTY" ]]
}

if [ "$ICON_OVERRIDE" = "emoji" ]; then
    SUCCESS_ICON="✅"
    ERROR_ICON="🚫"
    INFO_ICON="⚠️"
    SKIP_ICON="⏭️"
    COPY_ICON="📄"
    EXECUTE_ICON="⚙️"
    FOLDER_ICON="📁"
    TOOLS_ICON="🛠️"
    UPDATE_ICON="🔍"
    PACKAGE_ICON="📦"
    WORLD_ICON="🌎"
    SPACESHIP_ICON="🚀"
    COMPUTER_ICON="💻"
    SERVER_ICON="🔌"
    CLEAN_ICON="🧹"
    LOCK_ICON="🔒"
    BASHPROMPT_ICON="#️⃣ "
    SYMLINK_ICON="🔗"
    BITWARDEN_ICON="🛡️"
    INSTALL_ICON="📥"
    REPO_ICON="📚"
    VSCODE_ICON="⚛️"
    GHOSTTY_ICON="👻"
    NEOVIM_ICON="🇳"
    DEVKIT_ICON="🧰"
    GNOME_ICON="👣"
    DEPENDS_ICON="👨‍👨‍👦‍👦"
    GIT_ICON="🗂️"
    GITBRANCH_ICON="🪵"
    GITCOMMIT_ICON="📝"
    GITPUSH_ICON="🔄"
    GITHUB_ICON="😺"
    GITLAB_ICON="🦊" 
    GITEA_ICON="🫖"
    C_ICON="🇨"
    CSHARP_ICON="©️"
    DOCKER_ICON="⛴️"
    PYTHON_ICON="𓆙 "
    TYPESCRIPT_ICON="🇹"
    ADD_ICON="➕"
    BACK_ICON="↩️"
    EXIT_ICON="🚪"
    HEADER_ICON="*️⃣ "
elif [ "$ICON_OVERRIDE" = "nerd" ]; then
    SUCCESS_ICON="󰸞 "
    ERROR_ICON=" "
    INFO_ICON=" "
    SKIP_ICON="󰒭 "
    COPY_ICON=" "
    EXECUTE_ICON=" "
    FOLDER_ICON=" "
    TOOLS_ICON="󱁤 "
    UPDATE_ICON=" "
    PACKAGE_ICON=" "
    WORLD_ICON=" "
    SPACESHIP_ICON=" "
    COMPUTER_ICON="󰟀 "
    SERVER_ICON="󰒍 "
    CLEAN_ICON="󰃢 "
    LOCK_ICON=" "
    BASHPROMPT_ICON=" "
    SYMLINK_ICON=" "
    BITWARDEN_ICON=" "
    INSTALL_ICON=" "
    REPO_ICON=" "
    VSCODE_ICON=" "
    GHOSTTY_ICON="󰊠 "
    NEOVIM_ICON=" "
    DEVKIT_ICON=" "
    GNOME_ICON=" "
    DEPENDS_ICON=" "
    GIT_ICON=" "
    GITBRANCH_ICON=" "
    GITCOMMIT_ICON=" "
    GITPUSH_ICON=" "
    GITHUB_ICON=" "
    GITLAB_ICON=" "
    GITEA_ICON=" "
    C_ICON=" "
    CSHARP_ICON="󰌛 "
    DOCKER_ICON="󰡨 "
    PYTHON_ICON=" "
    TYPESCRIPT_ICON=" "
    ADD_ICON=" "
    BACK_ICON="󰌑 "
    EXIT_ICON="󰈆 "
    HEADER_ICON="󰎃 "
else
    SUCCESS_ICON="SUCCESS"
    ERROR_ICON="ERROR"
    INFO_ICON="INFO"
    SKIP_ICON="SKIP"
    COPY_ICON="FILE"
    EXECUTE_ICON="SETTING"
    FOLDER_ICON="FOLDER"
    TOOLS_ICON="TOOLS"
    UPDATE_ICON="UPDATE"
    PACKAGE_ICON="PACKAGE"
    WORLD_ICON="WORLD"
    SPACESHIP_ICON="SPACESHIP"
    COMPUTER_ICON="COMPUTER"
    SERVER_ICON="SERVER"
    CLEAN_ICON="CLEAN"
    LOCK_ICON="LOCK"
    BASHPROMT_ICON="#!"
    SYMLINK_ICON="SYMLINK"
    BITWARDEN_ICON="BITWARDEN"
    INSTALL_ICON="INSTALL"
    REPO_ICON="REPO"
    VCODE_ICON="VSCODE"
    GHOSTTY_ICON="GHOSTTY"
    NEOVIM_ICON="NEOVIM"
    DEVKIT_ICON="DEVKIT"
    GNOME_ICON="GNOME"
    DEPENDS_ICON="DEPENDENCIES"
    GIT_ICON="GIT"
    GITBRANCH_ICON="BRANCH"
    GITCOMMIT_ICON="COMMIT"
    GITPUSH_ICON="PUSH"
    GITHUB_ICON="GITHUB"
    GITLAB_ICON="GITLAB"
    GITEA_ICON="GITEA"
    C_ICON="[C ]"
    CSHARP_ICON="[C#]"
    DOCKER_ICON="[DO]"
    PYTHON_ICON="[PY]"
    TYPESCRIPT_ICON="[TS]"
    ADD_ICON="[+]"
    BACK_ICON="<-"
    EXIT_ICON="[>]"
    HEADER_ICON="[*]"
fi

RETURNED_INDEX=-1
### GENERAL UTILITY FUNCTIONS ###
cal-tui::clear_screen() {
    tput reset
}

cal-tui::print_header() {
    echo -e "${BOLD}${CYAN}${HEADER_ICON} $1 ${HEADER_ICON}${RESET}"
}

cal-tui::print_menu_item() {
    echo -e "  ${BOLD}${WHITE}$1)${RESET} ${YELLOW}$2 $3${RESET}"
}

cal-tui::print_info() {
    echo -e "${BOLD}${YELLOW}[${INFO_ICON}] $1${RESET}"
}

cal-tui::print_error() {
    echo -e "${BOLD}${RED}[${ERROR_ICON}]${MAGENTA} $1${RESET}"
}

cal-tui::print_log() {
    local icon="$1"; shift
    echo -e "${BOLD}${YELLOW}[${icon}] $*${RESET}"
}

cal-tui::print_success() {
    echo -e "${BOLD}${GREEN}[${SUCCESS_ICON}] $*${RESET}"
}

cal-tui::print_skip() {
    echo -e "${BOLD}${BLUE}[${SKIP_ICON}] $*${RESET}"
}

cal-tui::exit() {
     cal-tui::clear_screen
     echo "Goodbye $USER!"
     exit 0
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
    local regex='^[YyNn]$'
    local default_hint
    if [[ "$default" == "y" ]]; then
        default_hint="[Y/n]"
    else
        default_hint="[y/N]"
    fi

    local response
    while true; do
        #read -rp "$(echo -e "${CYAN}${prompt} ${default_hint} ${RESET}")" response
        response=$(cal-tui::input_prompt "$prompt $default_hint" true "$regex" "Use $default_hint")

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

### PROGRESS BAR ###
# Usage: cal-tui::progress_bar 3 10
cal-tui::progress_bar() {
    local current=$1
    local total=$2
    local width=0
    if [[ "$ICON_OVERRIDE" = "emoji" ]]; then
        width=75
    else
        width=150
    fi

    local percent=$(( 100 * current / total ))
    local filled=$(( width * current / total ))
    local empty=$(( width - filled ))
   
    local bar=""
    if [ "$ICON_OVERRIDE" = "emoji" ]; then
        for ((i=1; i<=filled; i++)); do
            bar+="⬜"
        done
        if ((empty != 0)); then
            for ((i=0; i<empty; i++)); do
                    bar+="◼️" 
            done
        fi
        printf "\r%s %d%%" "$bar" "$percent"
        if [[ "$current" -eq "$total" ]]; then
            echo ""
        fi
    elif [ "$ICON_OVERRIDE" = "nerd" ]; then
        if [ "$filled" -gt 0 ]; then
            bar=""
            for ((i=1; i<filled; i++)); do
                bar+=""
            done
            for ((i=0; i<empty; i++)); do
                    bar+="" 
            done

            if [[ "$filled" -eq "$width" ]]; then
                bar+=""
            else
                bar+=""
            fi
        else
            bar=""
            for ((i=0; i<empty; i++)); do
                    bar+="" 
            done
            bar+=""
        fi
        printf "\r%s %d%%" "$bar" "$percent"
        if [[ "$current" -eq "$total" ]]; then
            echo ""
        fi
    else
        bar=$(printf "%${filled}s" | tr '  ' '#')
        local space
        space=$(printf "%${empty}s")
        printf "\r[%s%s] %d%%" "$bar" "$space" "$percent"
        if [[ "$current" -eq "$total" ]]; then
            echo ""
        fi
    fi
}

cal-tui::table() {
    local -a lines
    local -A col_widths
    local border_left border_right border_sep
    local ICON_MODE="${ICON_OVERRIDE:-text}"
    local header_shown=false

    # Determine borders based on ICON_OVERRIDE
    case "$ICON_MODE" in
        emoji)
            border_left="🟩"
            border_right="🟩"
            border_sep="🟩"
            ;;
        nerd)
            border_left=""
            border_right=""
            border_sep="│"
            ;;
        *)
            border_left="|"
            border_right="|"
            border_sep="|"
            ;;
    esac

    # Read all lines into an array
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Compute max width of each column
    for line in "${lines[@]}"; do
        IFS=' ' read -r -a cols <<< "$line"
        for i in "${!cols[@]}"; do
            [[ ${#cols[i]} -gt ${col_widths[$i]:-0} ]] && col_widths[$i]=${#cols[i]}
        done
    done

    # Draw top border
    printf "${CYAN}"
    printf "%s" "$border_left"
    for i in "${!col_widths[@]}"; do
        printf "%s" "$(printf '─%.0s' $(seq 1 ${col_widths[$i]}))"
        [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$border_sep"
    done
    printf "%s\n" "$border_right"
    printf "${WHITE}"

    # Print each line with color and border
    for idx in "${!lines[@]}"; do
        IFS=' ' read -r -a cols <<< "${lines[$idx]}"
        printf "%s" "$border_left"
        for i in "${!cols[@]}"; do
            color="${WHITE}"
            [[ $i -eq 0 ]] && color="${GREEN}"
            [[ $i -eq 1 ]] && color="${YELLOW}"
            printf " ${color}%-*s${WHITE} " "${col_widths[$i]}" "${cols[$i]}"
            [[ $i -lt $((${#cols[@]} - 1)) ]] && printf "%s" "$border_sep"
        done
        printf "%s\n" "$border_right"

        # Show header separator under the first line
        if [[ $header_shown == false ]]; then
            printf "${CYAN}"
            printf "%s" "$border_left"
            for i in "${!col_widths[@]}"; do
                printf "%s" "$(printf '─%.0s' $(seq 1 ${col_widths[$i]}))"
                [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$border_sep"
            done
            printf "%s\n" "$border_right"
            printf "${WHITE}"
            header_shown=true
        fi
    done

    # Draw bottom border
    printf "${CYAN}"
    printf "%s" "$border_left"
    for i in "${!col_widths[@]}"; do
        printf "%s" "$(printf '─%.0s' $(seq 1 ${col_widths[$i]}))"
        [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$border_sep"
    done
    printf "%s\n" "$border_right"
    printf "${WHITE}"
}

### DYNAMIC MENU THAT RUNS COMMANDS ###
# Usage: cal-tui::main_menu "Title" "Option 1" "icon1" "cmd1" "Option 2" "icon2" "cmd2" ...
cal-tui::main_menu() {
    local title="$1"
    shift
    local -a options=()
    local -a commands=()
    local -a icons=()

    while [[ $# -gt 0 ]]; do
        options+=("$1")
        shift
        icons+=("$1")
        shift
        commands+=("$1")
        shift
    done

    local rows cols
    rows=$(tput lines)
    cols=$(tput cols)

    while true; do
        cal-tui::clear_screen

        # Build the full menu content
        menu_lines=()
        menu_lines+=("$(cal-tui::print_header "$title")")
        menu_lines+=("")
        for i in "${!options[@]}"; do
            menu_lines+=("$(cal-tui::print_menu_item "$((i+1))" "${icons[i]}" "${options[i]}")")
        done
        menu_lines+=("")

        # Compute max visible width (excluding ANSI codes)
        local max_len=0
        for line in "${menu_lines[@]}"; do
            local stripped
            stripped=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
            (( ${#stripped} > max_len )) && max_len=${#stripped}
        done

        local start_col=$(( (cols - max_len) / 2 ))
        local start_row=$(( (rows - ${#menu_lines[@]}) / 2 ))

        # Add vertical padding
        for ((i = 0; i < start_row; i++)); do echo; done

        # Print the menu block
        for line in "${menu_lines[@]}"; do
            printf "%*s%s\n" "$start_col" "" "$line"
        done

        # Input prompt aligned to the menu block
        echo
        #read -rp "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" choice
        choice=$(cal-tui::input_prompt "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" true '^[0-9]+$' "Only digits allowed.")

        if (( choice >= 0 && choice <= ${#options[@]} )); then
            cal-tui::clear_screen
            eval "${commands[$((choice-1))]}"
        else
            cal-tui::print_error "Invalid choice. Try again."
            sleep 1
        fi
    done
}

# DYNAMIC MENU THAT RETURNS INDEX OF SELECTED OPTION
# Usage: index=$(cal-tui::main_menu_return_index "Title" OPTIONS ICONS)
cal-tui::main_menu_return_index() {
    local title="$1"
    shift
    local -n _options=$1
    local -n _icons=$2
    local rows cols
    rows=$(tput lines)
    cols=$(tput cols)

    while true; do
        cal-tui::clear_screen

        # Prepare menu lines (without printing yet)
        menu_lines=()
        menu_lines+=("$(cal-tui::print_header "$title")")
        menu_lines+=("")
        for i in "${!_options[@]}"; do 
            menu_lines+=("$(cal-tui::print_menu_item "$((i+1))" "${_icons[i]}" "${_options[i]}")")
        done
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
        #read -rp "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" choice
        choice=$(cal-tui::input_prompt "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" true '^[0-9]+$' "Only digits allowed.")
        if (( choice >= 0 && choice <= ${#_options[@]} )); then
            # shellcheck disable=SC2034
            RETURNED_INDEX=$((choice-1))
            return
        else
            cal-tui::print_error "Invalid choice. Try again."
            sleep 1
        fi
    done
}
