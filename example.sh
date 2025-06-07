#!/usr/bin/env bash
# example.sh - Demonstrates use of the Bash TUI library

source ./cal-tui.sh

show_info() {
  name=$(cal-tui::input_prompt "Enter your name:" true '^[A-Za-z]+$' "Letters only!")
  age=$(cal-tui::input_prompt "Enter your age:" true '^[0-9]+$' "Only digits allowed.")
  cal-tui::print_success "Hello $name, age $age!"

  if cal-tui::confirm_prompt "Do you want to run a progress bar demo?" "y"; then
    for i in {1..20}; do
      sleep 0.1
      cal-tui::progress_bar "$i" 20
    done
  fi
}

main() {
  cal-tui::main_menu "Demo Menu" \
    "Input Prompt & Progress Bar" "show_info" \
    "Exit" "exit"
}

main

