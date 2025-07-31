#!/usr/bin/env bash
# shellcheck disable=SC2034 
# === cal-tui.sh - A minimal, reusable TUI (Text-based User Interface) Bash library
# === License: MIT
# === Source: https://github.com/calahil/cal-tui

# DELIM="|"
# === DEFAULT DELIMITER === 
# === can be overridden by setting DELIM globally
: "${DELIM:=|}"

# === STATE VARIABLE ===
CAL_STATE=""

# === CODE DEFINITIONS ===
RESET="\033[0m"
BOLD="\033[1m"
REVERSE="\033[7m"
UNDERLINE="\033[4m"

# === FOREGROUND COLORS ===
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

# === ICON SUPPORT ===
ICON_OVERRIDE="${CALDEV_ICON:-nerd}"

has_nerd_font() {
    fc-list | grep -qi "Nerd Font"
}
has_emoji_support() {
    [[ "$TERM" != "dumb" ]] && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" || -n "$SSH_TTY" ]]
}

declare -A ICON_MAP

# === available options  "emoji" "nerd" "text"
# === Usage: cal-tui::init_icons "nerd"
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
            [ADD]="➕" [MINUS]="➖" [BACK]="↩️" [EXIT]="🚪" [HEADER]="*️⃣ " [CLOCK]="⏰"
            [CALENDER]="📅" [PROMPT]="💲" [UP]="🔼 " [DOWN]="🔽 " [LOG]="📜"
            [GREEN_DOT]="🟢" [RED_DOT]="🔴" [PLEX]="🎬" [SWARM]="🐝" [REMOTE]="🖥️"
            [KEYBOARD]="⌨️"
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
            [ADD]=" " [MINUS]=" " [BACK]="󰌑 " [EXIT]="󰈆 " [HEADER]="󰎃 " [CLOCK]=" "
            [CALENDER]=" " [PROMPT]=" " [UP]=" " [DOWN]=" " [LOG]=" "
            [GREEN_DOT]="󰳘 " [RED_DOT]="󰱦 " [PLEX]="󰚺 " [SWARM]="󱃎 "
            [REMOTE]="󰢹 " [KEYBOARD]=" "
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
            [ADD]="[+]" [MINUS]="[-]" [BACK]="<-" [EXIT]="[>]" [HEADER]="[*]" [CLOCK]="TIME"
            [CALENDAR]="DATE" [PROMPT]="[$]" [UP]="UP" [DOWN]="DOWN" [LOG]="LOG"
            [GREEN_DOT]="UP" [RED_DOT]="DOWN" [PLEX]="PLEX" [SWARM]="SWARM"
            [REMOTE]="REMOTE" [KEYBOARD]="KEYS"
        )
    fi
}

cal-tui::get_icon() {
    local key="$1"
    echo "${ICON_MAP[$key]:-}"
}

safe_tput_cup() {
    local row=$1
    local col=$2
    (( row < 0 )) && row=0
    (( col < 0 )) && col=0
    tput cup "$row" "$col"
}

# === GENERAL UTILITY FUNCTIONS ===
cal-tui::clear_screen() {
    tput reset
}

cal-tui::print_header() {
    echo -e "${BOLD}${CYAN}${UNDERLINE}$(cal-tui::get_icon HEADER) $1 $(cal-tui::get_icon HEADER)${RESET}"
}

cal-tui::print_menu_item() {
    # $1 = number, $2 = icon, $3 = text, $4 = selected
    # Output without padding, caller will handle width
    if [[ "$4" == "true" ]]; then
        echo -e "${BOLD}${BLUE}${REVERSE}${BLUE} [$1] $2 $3 ${RESET}${BOLD}${BLUE}${RESET}"
    else
        echo -e "${BOLD}${WHITE}  [$1]${RESET} ${BLUE}$2${RESET} ${BOLD}${YELLOW}$3  ${RESET}"
    fi
}

cal-tui::print_help_header() {
    echo -e "${BOLD}${CYAN}$(cal-tui::get_icon KEYBOARD) $1 $(cal-tui::get_icon KEYBOARD)${RESET}"
}


cal-tui::print_info() {
    echo -e "${BOLD}${YELLOW}[$(cal-tui::get_icon INFO)] ${BOLD}${YELLOW}$1${RESET}" >&2
}

cal-tui::print_error() {
    echo -e "${BOLD}${RED}[$(cal-tui::get_icon ERROR)]${MAGENTA} $1${RESET}" >&2
}

cal-tui::print_log() {
    local icon="$1"; shift
    echo -e "${BOLD}${YELLOW}[${icon}]${YELLOW} $*${RESET}" >&2
}

cal-tui::print_success() {
    echo -e "${BOLD}${GREEN}[$(cal-tui::get_icon SUCCESS)] $*${RESET}" >&2
}

cal-tui::print_skip() {
    echo -e "${BOLD}${BLUE}[$(cal-tui::get_icon SKIP)] $*${RESET}" >&2
}

cal-tui::exit() {
     cal-tui::clear_screen
     echo -e "${REVERSE}Goodbye $USER!${RESET}"
     exit 0
}

cal-tui::strip_ansi() {
    # Usage: cal-tui::strip_ansi "$string"
    # Outputs string without ANSI color codes
    echo -e "$1" | sed -r 's/\x1B\[[0-9;]*[mK]//g'
}

# === INPUT WITH VALIDATION ===
# === Usage: input=$(cal-tui::input_prompt "Prompt text" required(true) 'regex' 'Error message' singlekey(true))
cal-tui::input_prompt() {
    local prompt="$1"
    local required="${2:-false}"
    local regex="${3:-}"
    local error_message="${4:-Invalid input.}"
    local singlekey="${5:-false}"

    local input=""
    while true; do
        local input
        if [[ "$singlekey" == true ]]; then
            echo -e "${CYAN}${prompt} ${RESET}" >&2 
            read -rsn1 input
            echo  # Print newline after keypress
        else
            read -rp "$(echo -e "${CYAN}${prompt} ${RESET}")" input
        fi

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

# === YES/NO CONFIRMATION ===
# === Usage: if cal-tui::confirm_prompt "Are you sure?" "n"; then ...
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
        response=$(cal-tui::input_prompt "$prompt $default_hint" true "$regex" "Use $default_hint" true)
        
        response="${response,,}"
        response="${response//[$'\r\n']}"
        
        if [[ -z "$response" ]]; then
            response="$default"
        fi

        case "$response" in
            [y]) return 0 ;;
            [n]) return 1 ;;
            *) cal-tui::print_error "Please answer y or n." ;;
        esac
    done
}

# === PROGRESS BAR ===
# === Usage: cal-tui::progress_bar 3 10
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

# === STRING BUILDER ===
# === Usage: var=$(cal-tui::build_string "ssh" "$host" "command")
cal-tui::build_string() {
    local delim="${DELIM}"
    local result=""
    local first=1
    for arg in "$@"; do
        # === Escape delimiter inside arguments
        arg="${arg//${delim}/${delim}${delim}}"
        if [[ $first -eq 1 ]]; then
            result="$arg"
            first=0
        else
            result+="${delim}${arg}"
        fi
    done
    echo "$result"
}

# === ARRAY FROM STRING BUILDER ===  (requires Bash ≥ 4.3)
# === Usage: cal-tui::parse_string "$built_string" out_array
cal-tui::parse_string() {
    local input="$1"
    local out_array_name="$2"
    local delim="${DELIM}"
    local temp_delim=$'\x1F'

    # === Replace escaped delimiters with temp token
    input="${input//${delim}${delim}/${temp_delim}}"

    local -a result=()
    IFS="$delim" read -ra fields <<< "$input"
    for field in "${fields[@]}"; do
        result+=("${field//${temp_delim}/${delim}}")
    done

    # === Return array using nameref, no eval needed
    declare -n out_array="$out_array_name"
    out_array=("${result[@]}")
}

# === RUNS COMMANDS ===
# === Usage: cal-tui::proxy_run COMMANDS CALLBACK
cal-tui::proxy_run() {
    local packed_command="$1"
    local packed_callback="$2"
    local -a unpacked_command
    local -a unpacked_callback

    cal-tui::parse_string "$packed_command" unpacked_command
    cal-tui::parse_string "$packed_callback" unpacked_callback

    "${unpacked_command[@]}"
    if cal-tui::confirm_prompt "Return to Menu?" "y"; then
        echo "${unpacked_callback[@]}"
        "${unpacked_callback[@]}"
    else
        cal-tui::exit
    fi 
}

cal-tui::print_widgets() {
    local col=$1
    # === CORNER INFO ===
    safe_tput_cup 0 0
    echo -ne "${CYAN}$(cal-tui::get_icon COMPUTER) $(hostname)${RESET}"
    safe_tput_cup 0 $((col))
    echo -ne "${MAGENTA}$(cal-tui::get_icon PROMPT) Shells: $SHLVL${RESET}"
    safe_tput_cup 1 0
    echo -ne "${BLUE}$(cal-tui::get_icon CLOCK) $(date +%T)${RESET}"
    safe_tput_cup 1 $((col))
    echo -ne "${YELLOW}$(cal-tui::get_icon CALENDAR) $(date +%Y-%m-%d)${RESET}"
}

cal-tui::print_help_menu() {
    # $1 = _keymap_name
    # # Output without padding, caller will handle width
    local keybind_menu="Keybind Help"
    local -n _keymap_names=$1
    local -a keys=(
        "↑/k" "↓/j" "←/h" "→/l" 
        "1-9" " 󰌑 " " 󰭜 " " 󱊷 "
        " W " " A " " S " " D "
        )
    local -a desc=(
        "Move Up" "Move Down" "Page Back" "Page Forward"
        "Select Index" "Select Current" "Previous Menu" "Quit"
        "${keymap_name[0]:-Not Bound}" "${keymap_name[1]:-Not Bound}" "${keymap_name[2]:-Not Bound}" "${keymap_name[3]:-Not Bound}"        
        )
            
    local columns
    columns=$(tput cols)
    local rows
    rows=$(tput lines)
    local column_width=$((columns / 4))
    local total_columns=4
    local current_column=0
    local header_row=$((rows - 4))

    safe_tput_cup $((header_row)) $(( (cols - (${#keybind_menu} + 6))  / 2 ))
    cal-tui::print_help_header "$keybind_menu"

    local -a sections=()
    for ((i=0; i<${#keys[@]}; i++)); do
        if ((i < total_columns)); then
            safe_tput_cup $((header_row + 1)) $((column_width * current_column))
            echo -ne "${BOLD}${CYAN}[${keys[i]}]${RESET} ${BLUE}${desc[$i]}${RESET}"
            current_column=$((current_column + 1))
            if ((current_column == 4)); then
                current_column=0
            fi
        elif ((i < (total_columns * 2))); then
            safe_tput_cup $((header_row + 2)) $((column_width * current_column))
            echo -ne "${BOLD}${CYAN}[${keys[i]}]${RESET} ${BLUE}${desc[$i]}${RESET}"
            current_column=$((current_column + 1))
            if ((current_column == 4)); then
                current_column=0
            fi
        else
            safe_tput_cup $((header_row + 3)) $((column_width * current_column))
            echo -ne "${BOLD}${CYAN}[${keys[i]}]${RESET} ${BLUE}${desc[$i]}${RESET}"
            current_column=$((current_column + 1))
            if ((current_column == 4)); then
                current_column=0
            fi

        fi
    done
}

# === DYNAMIC MENU THAT RUNS COMMANDS ===
# === Usage: cal-tui::menu "Title" OPTIONS ICONS COMMANDS CALLBACK KEYMAP_CMD KEYMAP_NAME
cal-tui::menu() {
    local title="$1"
    shift
    local -n _options=$1
    local -n _icons=$2
    local -n _commands=$3
    local -n _callback=$4
    local -n _keymap_cmds=$5
    local -n _keymap_name=$6

    local MAX_ROWS=9
    local MAX_COLS=1
    local PAGE_SIZE=$((MAX_ROWS * MAX_COLS))

    local rows cols
    rows=$(tput lines)
    cols=$(tput cols)

    local current_page=0
    local selected_index=0
    local total_items=${#_options[@]}
    local total_pages=$(( (total_items + PAGE_SIZE - 1) / PAGE_SIZE ))

    
    local need_redraw=true
    tput civis
    while true; do
        if $need_redraw; then
            need_redraw=false
            # Clamp page range
            (( current_page < 0 )) && current_page=0
            (( current_page >= total_pages )) && current_page=$((total_pages - 1))

            # Clamp selection to current page
            local page_start=$((current_page * PAGE_SIZE))
            local page_end=$((page_start + PAGE_SIZE - 1))
            (( page_end >= total_items )) && page_end=$((total_items - 1))
            (( selected_index < page_start )) && selected_index=$page_start
            (( selected_index > page_end )) && selected_index=$page_start

            cal-tui::clear_screen

            cal-tui::print_widgets $((cols - 16))
            # === Layout Computation ===
            local max_width=0
            for ((i = 0; i < total_items; i++)); do
                local item
                local selected=false
                if ((i == selected_index)); then
                    selected=true
                fi
                
                item="$(cal-tui::print_menu_item "$((i+1))" "${_icons[i]}" "${_options[i]}" "${selected}")"
                local stripped
                stripped=$(cal-tui::strip_ansi "$item")
                (( ${#stripped} > max_width )) && max_width=${#stripped}
            done
            local col_padding=4
            local col_width=$((max_width + col_padding))
            local grid_width=$((col_width * MAX_COLS))
            local start_col=$(( (cols - grid_width) / 2 ))
            local grid_height=$((MAX_ROWS + 3))
            local start_row=$(( (rows - grid_height) / 2 ))
            (( start_col < 0 )) && start_col=0
            (( start_row < 0 )) && start_row=0

            # === Header ===
            safe_tput_cup "$start_row" $(( (cols - (${#title} + 6)) / 2 ))
            if ((total_pages > 1)); then
                cal-tui::print_header "$title $(cal-tui::get_icon COPY) ${CYAN}[Page $((current_page + 1)) of $total_pages]${RESET}"
            else
                cal-tui::print_header "$title"
            fi
            safe_tput_cup $((start_row + 1)) 0
            echo
            # === Print Menu Items ===
            for ((r = 0; r < MAX_ROWS; r++)); do
                safe_tput_cup $((start_row + 2 + r)) "$start_col"
                local index=$((page_start + r))
                if (( index > page_end )); then
                    printf "%*s\n" "$col_width" ""
                    continue
                fi

                local label_num=$((index + 1))

                local item
                local selected=false
                if ((index == selected_index)); then
                    selected=true
                fi

                item="$(cal-tui::print_menu_item "$label_num" "${_icons[index]}" "${_options[index]}" "${selected}")"
                local stripped
                stripped=$(cal-tui::strip_ansi "$item")
                local pad=$((col_width - ${#stripped}))
                printf "%s%*s\n" "$item" "$pad" ""
            done

            # === Footer ===
           
            local -a keynames=(${_keymap_name[@]})
            cal-tui::print_help_menu keynames
        fi
        cols=$(tput cols)



        # Move cursor to the last column of the current line
        safe_tput_cup $(($(tput lines) - 1)) $((cols - 1))
        # === Read Input ===
        IFS= read -rsn1 key || key=""
        if [[ "$key" == $'\e' ]]; then
            IFS= read -rsn2 -t 0.1 rest || rest=""
            key+="$rest"
        fi

        case "$key" in
            [1-9])
                local idx=$(( (current_page * PAGE_SIZE) + key - 1 ))
                if (( idx < total_items )); then
                    cal-tui::clear_screen
                    cal-tui::proxy_run "${_commands[$idx]}" "$_callback"
                    return
                fi
                ;;
            h|$'\e[D') # Left
                if (( current_page > 0 )); then
                    ((current_page--))
                    need_redraw=true
                fi
                ;;
            l|$'\e[C') # Right
                if (( current_page < total_pages - 1 )); then
                    ((current_page++))
                    need_redraw=true
                fi
                ;;                
            j|$'\e[B') # Down
                if (( selected_index < page_end )); then
                    echo "selected_index=$selected_index, page_end=$page_end, total_items=$total_items" >&2
                    ((selected_index=selected_index + 1))
                    need_redraw=true
                fi
                ;;
            k|$'\e[A') # Up
                if (( selected_index > 0 )); then
                    ((selected_index--))
                    need_redraw=true
                fi
                ;;
            $'\n'|$'\r'|$'\0') # Enter
                cal-tui::clear_screen
                cal-tui::proxy_run "${_commands[$selected_index]}" "$_callback"
                return
                ;;
            $'\e') # ESC
                cal-tui::exit
                ;;
            $'\x7f') # Backspace
                cal-tui::clear_screen
                return
                ;;
            [wasd])
                local idx
                case "$key" in
                    w) idx=0 ;;
                    a) idx=1 ;;
                    s) idx=2 ;;
                    d) idx=3 ;;
                esac
                if [[ -n "${_keymap_cmds[$idx]}" ]]; then
                    cal-tui::clear_screen
                    cal-tui::proxy_run "${_keymap_cmds[$idx]}" "$_callback"
                fi
                ;;
        esac
    done
    tput cnorm
}

# cal-tui::menu() {
#     local title="$1"
#     shift
#     local -n _options=$1
#     local -n _icons=$2
#     local -n _commands=$3
#     local -n _callback=$4
#     local -n _keymap_cmds=$5
#     local -n _keymap_name=$6
#
#     local rows cols
#     rows=$(tput lines)
#     cols=$(tput cols)
#
#     while true; do
#         cal-tui::clear_screen
#
#         # === CORNER INFO ===
#         tput cup 0 0
#         echo -ne "${CYAN}$(cal-tui::get_icon COMPUTER) $(hostname)${RESET}"
#         tput cup 0 $((cols - 16))
#         echo -ne "${MAGENTA}$(cal-tui::get_icon PROMPT) Shells: $SHLVL${RESET}"
#         tput cup 1 0
#         echo -ne "${BLUE}$(cal-tui::get_icon CLOCK) $(date +%T)${RESET}"
#         tput cup 1 $((cols - 16))
#         echo -ne "${YELLOW}$(cal-tui::get_icon CALENDAR) $(date +%Y-%m-%d)${RESET}"
#         tput cup 2 0
#         echo -ne "W: ${_keymap_name[0]:-Not Bound}"
#         tput cup 2 $((cols - 16))
#         echo -ne "A: ${_keymap_name[1]:-Not Bound}"
#         tput cup 3 0
#         echo -ne "S: ${_keymap_name[2]:-Not Bound}"
#         tput cup 3 $((cols - 16))
#         echo -ne "D: ${_keymap_name[3]:-Not Bound}"
#         
#         # === Build the menu
#         menu_lines=()
#         menu_lines+=("$(cal-tui::print_header "$title")")
#         menu_lines+=("")
#         for i in "${!_options[@]}"; do
#             menu_lines+=("$(cal-tui::print_menu_item "$((i+1))" "${_icons[i]}" "${_options[i]}")")
#         done
#         menu_lines+=("")
#
#         local max_len=0
#         for line in "${menu_lines[@]}"; do
#             local stripped
#             stripped=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
#             (( ${#stripped} > max_len )) && max_len=${#stripped}
#         done
#
#         local start_col=$(( (cols - max_len) / 2 ))
#         local start_row=$(( (rows - ${#menu_lines[@]}) / 2 ))
#
#         for ((i = 0; i < start_row; i++)); do echo; done
#         for line in "${menu_lines[@]}"; do
#             printf "%*s%s\n" "$start_col" "" "$line"
#         done
#
#         echo
#         printf "%*s%s" "$start_col" "" "(0-9 | w/a/s/d | ESC | BACKSPACE): "
#         IFS= read -rsn1 key
#
#         case "$key" in
#             [0-9])
#                 if (( key >= 1 && key <= ${#_options[@]} )); then
#                     cal-tui::clear_screen
#                     local cmd="${_commands[$((key - 1))]}"
#                     cal-tui::proxy_run "$cmd" "$_callback"
#                     return
#                 fi
#                 ;;
#             $'\e') # ESC
#                 cal-tui::exit
#                 ;;
#             $'\x7f')  # Backspace
#                 cal-tui::clear_screen
#                 return
#                 ;;
#             [wasd])
#                 idx=""
#                 case "$key" in
#                     w) idx=0 ;;
#                     a) idx=1 ;;
#                     s) idx=2 ;;
#                     d) idx=3 ;;
#                 esac
#
#                 if [[ -n "${_keymap_cmds[$idx]}" ]]; then
#                     cal-tui::clear_screen
#                     local cmd="${_keymap_cmds[$idx]}"
#                     cal-tui::proxy_run "$cmd" "$_callback"
#                 fi
#                 ;;
#         esac
#     done
# }
# # === DYNAMIC MENU THAT RUNS COMMANDS ===
# # === Usage: cal-tui::menu "Title" OPTIONS ICONS COMMANDS CALLBACK
# cal-tui::menu() {
#     local title="$1"
#     shift
#     local -n _options=$1
#     local -n _icons=$2
#     local -n _commands=$3
#     local -n _callback=$4
#
#     local rows cols
#     rows=$(tput lines)
#     cols=$(tput cols)
#
#     while true; do
#         cal-tui::clear_screen
#         
#         # === CORNER INFO ===
#         # === Top-left: Hostname
#         tput cup 0 0
#         echo -ne "${CYAN}$(cal-tui::get_icon COMPUTER) $(hostname)${RESET}"
#
#         # === Top-right: SHLVL
#         tput cup 0 $((cols - 16))
#         echo -ne "${MAGENTA}$(cal-tui::get_icon PROMPT) Shells: $SHLVL${RESET}"
#
#         # === Bottom-left: Time
#         tput cup 1 0
#         echo -ne "${BLUE}$(cal-tui::get_icon CLOCK) $(date +%T)${RESET}"
#
#         # === Bottom-right: Date
#         tput cup 1 $((cols - 16))
#         echo -ne "${YELLOW}$(cal-tui::get_icon CALENDAR) $(date +%Y-%m-%d)${RESET}"
#         
#         # === Bottom-left: Time
#         
#         # === Build the menu
#         menu_lines=()
#         menu_lines+=("$(cal-tui::print_header "$title")")
#         menu_lines+=("")
#         for i in "${!_options[@]}"; do
#             menu_lines+=("$(cal-tui::print_menu_item "$((i+1))" "${_icons[i]}" "${_options[i]}")")
#         done
#         menu_lines+=("")
#
#         # === Compute max visible width (excluding ANSI codes)
#         local max_len=0
#         for line in "${menu_lines[@]}"; do
#             local stripped
#             stripped=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
#             (( ${#stripped} > max_len )) && max_len=${#stripped}
#         done
#
#         local start_col=$(( (cols - max_len) / 2 ))
#         local start_row=$(( (rows - ${#menu_lines[@]}) / 2 ))
#
#         # === Add vertical padding
#         for ((i = 0; i < start_row; i++)); do echo; done
#
#         # === Print the menu block
#         for line in "${menu_lines[@]}"; do
#             printf "%*s%s\n" "$start_col" "" "$line"
#         done
#
#         # === Input prompt aligned to the menu block
#         echo
#         choice=$(cal-tui::input_prompt "$(printf "%*s%s" "$start_col" "" "Choose an option: ")" true '^[0-9]+$' "Only digits allowed.")
#
#         if (( choice >= 1 && choice <= ${#_options[@]} )); then
#             cal-tui::clear_screen
#             local cmd="${_commands[$((choice-1))]}"
#             local callback="${_callback[$((choice -1))]}"
#
#             cal-tui::proxy_run "$cmd" "$callback"
#             return
#         fi
#     done
# }
