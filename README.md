# Cal TUI Library

A minimal reusable Text-based User Interface (TUI) toolkit for Bash scripting. Build beautiful CLI interfaces with color, menus, input validation, progress bars, and confirmations.

## Features

- ✅ Colorized text output (info, success, error)
- 🔄 Dynamic, argument-driven menu system
- 🟩 Relative progress bar
- 📝 Input with required/regex validation
- ❓ Yes/No confirmation prompt
- ⚠️ Emoji/Nerd Font/plain text support 
- 🌐 Installable via `curl`

---

## Getting Started

### 🔧 Quick Install
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/calahil/cal-tui/main/install.sh)"
source $HOME/.local/bin/cal-tui.sh
```

Or manually:
```bash
curl -fsSL https://raw.githubusercontent.com/calahil/cal-tui/main/cal-tui.sh -o $HOME/.local/bin/cal-tui.sh
source $HOME/.local/bin/cal-tui.sh
```

### 📁 File Structure
```
cal-tui/
├── cal-tui.sh                # The TUI library
├── example.sh                # Demo script
├── install.sh                # Curl-installable setup
├── .gitlab-ci.yml            # GitLab CI runners
├── .github/workflows/        # GitHub Actions CI
│   └── main.yml
├── README.md                 # Docs (this file)
└── LICENSE                   # MIT License
```

---

## 🧪 Example Usage

### Menu
```bash
source $HOME/.local/bin/cal-tui.sh

my_func() {
  cal-tui::print_info "This is a menu option."
}

cal-tui::main_menu "Main Menu" \
  "Do something" "icon1" "my_func" \
  "Quit" "icon2" "exit"
```

### Input With Validation
```bash
name=$(cal-tui::input_prompt "Enter your name:" true '^[A-Za-z]+$' "Letters only!")
```

### Progress Bar
```bash
for i in {1..10}; do
  sleep 0.1
  cal-tui::progress_bar $i 10
done
```

### Confirmation Prompt
```bash
if cal-tui::confirm_prompt "Continue with installation?" "n"; then
  cal-tui::print_success "Proceeding."
else
  cal-tui::print_info "Canceled."
fi
```

---

## 🚀 License
MIT License. See `LICENSE` file for full text.

---

## 🔗 Contributing / Roadmap
- [x] Colorized output
- [x] Progress bar
- [x] Input validation
- [x] Yes/No prompt
- [x] Dynamic menu
- [x] Install via curl
- [x] Icon support
- [ ] Tables
- [ ] Multi-field form input
- [ ] Popup/dialog UI
- [ ] Animated spinners

Fork, PR, or open an issue to suggest features or improvements.

---

Made with ❤️ in Bash.

