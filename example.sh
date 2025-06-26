#!/usr/bin/env bash
# shellcheck disable=SC2034
# example.sh - Demonstrates use of the Bash TUI library

source ./cal-tui.sh

show_info() {
    name=$(cal-tui::input_prompt "Enter your name:" true '^[A-Za-z]+$' "Letters only!")
    age=$(cal-tui::input_prompt "Enter your age:" true '^[0-9]+$' "Only digits allowed.")
    cal-tui::print_success "Hello $name, age $age!"
    sleep 5
}

show_progress() {
    if cal-tui::confirm_prompt "Do you want to run a progress bar demo?" "y"; then
        for i in {1..20}; do
            sleep 0.1
            cal-tui::progress_bar "$i" 20
        done
    fi
}

main() {
    cal-tui::init_icons "nerd"
    local -a options=(
        "Input Prompt" 
        "Progress Bar" 
        "Print Success" 
        "Exit"
    )
    local -a icons=(
        "$(cal-tui::get_icon BASHPROMPT)" 
        "$(cal-tui::get_icon SPACESHIP)" 
        "$(cal-tui::get_icon SUCCESS)"
        "$(cal-tui::get_icon EXIT)"
    )
    local -a commands=(
        "bash" 
        "show_progress" 
        "show_info" 
        "cal-tui::exit"
    )

    cal-tui::menu "Demo Menu" options icons commands
}

main
