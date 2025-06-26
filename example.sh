#!/usr/bin/env bash
# shellcheck disable=SC2034
# === example.sh - Demonstrates use of the Bash TUI library

source ./cal-tui.sh

show_info() {
    name=$(cal-tui::input_prompt "Enter your name:" true '^[A-Za-z]+$' "Letters only!")
    age=$(cal-tui::input_prompt "Enter your age:" true '^[0-9]+$' "Only digits allowed.")
    cal-tui::print_success "Hello $name, age $age!"
    sleep 5
}

show_progress() {
    local header="$1"
    if cal-tui::confirm_prompt "Do you want to run a progress bar demo?" "y"; then
        cal-tui::print_header "$header"
        for i in {1..20}; do
            sleep 0.1
            cal-tui::progress_bar "$i" 20
        done
    fi
}

main() {
    cal-tui::init_icons "nerd"
    local -a options=(
        "Bash" 
        "Progress Bar"
        "Show Info"
        "Print Success" 
        "Exit"
    )
    local -a icons=(
        "$(cal-tui::get_icon BASHPROMPT)" 
        "$(cal-tui::get_icon SPACESHIP)" 
        "$(cal-tui::get_icon SUCCESS)"
        "$(cal-tui::get_icon INFO)"
        "$(cal-tui::get_icon EXIT)"
    )
    local -a commands=(
        "bash" 
        "$(cal-tui::build_string "show_progress" "Header")" 
        "show_info"
        "$(cal-tui::build_string "cal-tui::print_success" "Great Job!")"
        "cal-tui::exit"
    )
    local -a callbacks=(
        "main"
        "main"
        "main"
        "main"
        ""
    )
    cal-tui::menu "Demo Menu" options icons commands callbacks
}

main
