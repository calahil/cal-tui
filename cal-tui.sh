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

declare -A ICON_MAP

cal-tui::init_icons() {
    local mode="${1:-$ICON_OVERRIDE}"

    if [[ $mode == "emoji" ]]; then
        ICON_MAP=(
            [SUCCESS]="✅" [ERROR]="🚫" [INFO]="⚠️" [SKIP]="⏭️"
            [COPY]="📄" [EXECUTE]="⚙️" [FOLDER]="📁" [TOOLS]="🛠️"
            [UPDATE]="🔍" [PACKAGE]="📦" [WORLD]="🌎" [SPACESHIP]="🚀"
            [COMPUTER]="💻" [SERVER]="🔌" [CLEAN]="🧹" [LOCK]="🔒"
            [BASHPROMPT]="#️⃣ " [SYMLINK]="🔗" [BITWARDEN]="🛡️"
            [INSTALL]="📥" [REPO]="📚" [VSCODE]="⚛️" [GHOSTTY]="👻"
            [NEOVIM]="🇳" [DEVKIT]="🧰" [GNOME]="👣" [DEPENDS]="👨‍👨‍👦‍👦"
            [GIT]="🗂️" [GITBRANCH]="🪵" [GITCOMMIT]="📝" [GITPUSH]="🔄"
            [GITHUB]="😺" [GITLAB]="🦊" [GITEA]="🫖" [C]="🇨"
            [CSHARP]="©️" [DOCKER]="⛴️" [PYTHON]="𓆙" [TYPESCRIPT]="🇹"
            [ADD]="➕" [BACK]="↩️" [EXIT]="🚪" [HEADER]="*️⃣ "
        )
    elif [[ $mode == "nerd" ]]; then
        ICON_MAP=(
            [SUCCESS]="󰸞 " [ERROR]=" " [INFO]=" " [SKIP]="󰒭 "
            [COPY]=" " [EXECUTE]=" " [FOLDER]=" " [TOOLS]="󱁤 "
            [UPDATE]=" " [PACKAGE]=" " [WORLD]=" " [SPACESHIP]=" "
            [COMPUTER]="󰟀 " [SERVER]="󰒍 " [CLEAN]="󰃢 " [LOCK]=" "
            [BASHPROMPT]=" " [SYMLINK]=" " [BITWARDEN]=" "
            [INSTALL]=" " [REPO]=" " [VSCODE]=" " [GHOSTTY]="󰊠 "
            [NEOVIM]=" " [DEVKIT]=" " [GNOME]=" " [DEPENDS]=" "
            [GIT]=" " [GITBRANCH]=" " [GITCOMMIT]=" " [GITPUSH]=" "
            [GITHUB]=" " [GITLAB]=" " [GITEA]=" " [C]=" "
            [CSHARP]="󰌛 " [DOCKER]="󰡨 " [PYTHON]=" " [TYPESCRIPT]=" "
            [ADD]=" " [BACK]="󰌑 " [EXIT]="󰈆 " [HEADER]="󰎃 "
        )
    else
        ICON_MAP=(
            [SUCCESS]="SUCCESS" [ERROR]="ERROR" [INFO]="INFO" [SKIP]="SKIP"
            [COPY]="FILE" [EXECUTE]="SETTING" [FOLDER]="FLDR" [TOOLS]="TOOLS"
            [UPDATE]="UPD" [PACKAGE]="PKG" [WORLD]="WRLD" [SPACESHIP]="SHIP"
            [COMPUTER]="PUTER" [SERVER]="SRV" [CLEAN]="CLEAN" [LOCK]="LOCK"
            [BASHPROMPT]="#!" [SYMLINK]="SYM" [BITWARDEN]="BIT"
            [INSTALL]="INSTALL" [REPO]="REPO" [VSCODE]="VSC" [GHOSTTY]="GHOSTTY"
            [NEOVIM]="NVIM" [DEVKIT]="DEVKIT" [GNOME]="GNOME" [DEPENDS]="DEPEND"
            [GIT]="GIT" [GITBRANCH]="BRANCH" [GITCOMMIT]="COMMIT" [GITPUSH]="PUSH"
            [GITHUB]="GITHUB" [GITLAB]="GITLAB" [GITEA]="GITEA" [C]="[C]" 
            [CSHARP]="[C#]" [DOCKER]="[DO]" [PYTHON]="[PY]" [TYPESCRIPT]="[TS]"
            [ADD]="[+]" [BACK]="<-" [EXIT]="[>]" [HEADER]="[*]"
        )
    fi
}

cal-tui::get_icon() {
    local key="$1"
    echo "${ICON_MAP[$key]:-}"
}

### GENERAL UTILITY FUNCTIONS ###
cal-tui::clear_screen() {
    tput reset
}

cal-tui::print_header() {
    echo -e "${BOLD}${CYAN}$(cal-tui::get_icon HEADER) $1 $(cal-tui::get_icon HEADER)${RESET}"
}

cal-tui::print_menu_item() {
    echo -e "  ${BOLD}${WHITE}$1)${RESET} ${YELLOW}$2 $3${RESET}"
}

cal-tui::print_info() {
    echo -e "${BOLD}${YELLOW}[$(cal-tui::get_icon INFO)] $1${RESET}" >&2
}

cal-tui::print_error() {
    echo -e "${BOLD}${RED}[$(cal-tui::get_icon ERROR)]${MAGENTA} $1${RESET}" >&2
}

cal-tui::print_log() {
    local icon="$1"; shift
    echo -e "${BOLD}${YELLOW}[${icon}] $*${RESET}" >&2
}

cal-tui::print_success() {
    echo -e "${BOLD}${GREEN}[$(cal-tui::get_icon SUCCESS)] $*${RESET}" >&2
}

cal-tui::print_skip() {
    echo -e "${BOLD}${BLUE}[$(cal-tui::get_icon SKIP)] $*${RESET}" >&2
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
        response=$(cal-tui::input_prompt "$prompt $default_hint" true "$regex" "Use $default_hint")

        response="${response,,}"

        if [[ -z "$response" ]]; then
            response="$default"
        fi

        case "$response" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) cal-tui::print_error "Please answer yes or no." ;;
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
        printf "\r%s %d%%" "$bar" "$percent"  >&2
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
        printf "\r%s %d%%" "$bar" "$percent" >&2
        if [[ "$current" -eq "$total" ]]; then
            echo "" >&2
        fi
    else
        bar=$(printf "%${filled}s" | tr '  ' '#')
        local space
        space=$(printf "%${empty}s")
        printf "\r[%s%s] %d%%" "$bar" "$space" "$percent" >&2
        if [[ "$current" -eq "$total" ]]; then
            echo ""
        fi
    fi
}

cal-tui::table() {
    local -a lines
    local -a col_widths
    local icon_mode="${ICON_OVERRIDE:-text}"
    local header_shown=false

    # Define border sets per mode
    local tl tr bl br h v sep
    case "$icon_mode" in
        emoji)
            tl="🟩"; tr="🟩"; bl="🟩"; br="🟩"
            h="🟩"; v="🟩"; sep="🟩"
            ;;
        nerd)
            tl="┌"; tr="┐"; bl="└"; br="┘"
            h="─"; v="│"; sep="│"
            ;;
        *)
            tl="+"; tr="+"; bl="+"; br="+"
            h="-"; v="|"; sep="|"
            ;;
    esac

    # Read input lines
    while IFS= read -r line; do
        lines+=("$line")
    done

    # Calculate column widths
    for line in "${lines[@]}"; do
        IFS=' ' read -r -a cols <<< "$line"
        for i in "${!cols[@]}"; do
            [[ ${#cols[i]} -gt ${col_widths[$i]:-0} ]] && col_widths[$i]=${#cols[i]}
        done
    done

    # Draw top border
    printf "${CYAN}${tl}"
    for i in "${!col_widths[@]}"; do
        printf '%*s' "${col_widths[$i]}" '' | tr ' ' "$h"
        [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$sep"
    done
    printf "${tr}\n${WHITE}"

    # Print rows
    for idx in "${!lines[@]}"; do
        IFS=' ' read -r -a cols <<< "${lines[$idx]}"
        printf "%s" "$v"
        for i in "${!cols[@]}"; do
            color="${WHITE}"
            [[ $i -eq 0 ]] && color="${GREEN}"
            [[ $i -eq 1 ]] && color="${YELLOW}"
            printf " ${color}%-*s${WHITE} " "${col_widths[$i]}" "${cols[$i]}"
            [[ $i -lt $((${#cols[@]} - 1)) ]] && printf "%s" "$sep"
        done
        printf "%s\n" "$v"

        # Header separator
        if [[ $header_shown == false ]]; then
            printf "${CYAN}${v}"
            for i in "${!col_widths[@]}"; do
                printf '%*s' "${col_widths[$i]}" '' | tr ' ' "$h"
                [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$sep"
            done
            printf "%s\n" "$v${WHITE}"
            header_shown=true
        fi
    done

    # Draw bottom border
    printf "${CYAN}${bl}"
    for i in "${!col_widths[@]}"; do
        printf '%*s' "${col_widths[$i]}" '' | tr ' ' "$h"
        [[ $i -lt $((${#col_widths[@]} - 1)) ]] && printf "%s" "$sep"
    done
    printf "${br}\n${WHITE}"
}

### DYNAMIC MENU THAT RUNS COMMANDS ###
# Usage: cal-tui::menu "Title" OPTIONS ICONS COMMANDS CMD_ARG
cal-tui::menu() {
    local title="$1"
    shift
    local -n _options=$1
    local -n _icons=$2
    local -n _commands=$3
    local -n _cmd_arg=$4

    local rows cols
    rows=$(tput lines)
    cols=$(tput cols)

    while true; do
        cal-tui::clear_screen

        # Build the full menu content
        menu_lines=()
        menu_lines+=("$(cal-tui::print_header "$title")")
        menu_lines+=("")
        for i in "${!_options[@]}"; do
            menu_lines+=("$(cal-tui::print_menu_item "$((i+1))" "${_icons[i]}" "${_options[i]}")")
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
        choice=$(cal-tui::input_prompt "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" true '^[0-9]+$' "Only digits allowed.")

        if (( choice >= 0 && choice <= ${#_options[@]} )); then
            cal-tui::clear_screen
            local cmd="${_commands[$((choice-1))]}"
            local args=("${_cmd_arg[$((choice -1))]}")
            
            "$cmd" "${args[@]}"
            return
        else
            cal-tui::print_error "Invalid choice. Try again."
            sleep 1
        fi
    done
}
