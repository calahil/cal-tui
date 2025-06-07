# Bash Cal-TUI Library

A lightweight, colorized, interactive TUI (Text-based User Interface) library for Bash scripts. Perfect for creating user-friendly CLI menus, input prompts, progress bars, and confirmations.

---

## ✨ Features

* ✅ Colorized output (info, success, error, headers)
* 📋 Dynamic main menu system
* ⌨️ Input prompts with validation
* 🟩 Progress bar based on percentage steps
* ❓ Yes/No confirmation dialogs

---

## 🛠 Installation

```bash
curl -O https://raw.githubusercontent.com/calahil/cal-tui/main/cal-tui.sh
chmod +x cal-tui.sh
```

Then source it in your scripts:

```bash
source ./cal-tui.sh
```

---

## 🧪 Example Usage

### Menu:

```bash
source ./cal-tui.sh

say_hello() {
    name=$(cal-tui::input_prompt "Enter your name:" true)
    cal-tui::print_success "Hello, $name!"
}

ask_delete() {
    if cal-tui::confirm_prompt "Delete all files?" "n"; then
        cal-tui::print_info "Files deleted."
    else
        cal-tui::print_info "Aborted."
    fi
}

cal-tui::main_menu "Main Menu" \
    "Say Hello" "say_hello" \
    "Delete Prompt" "ask_delete"
```

### Progress Bar:

```bash
for i in {1..10}; do
    sleep 0.2
    cal-tui::progress_bar "$i" 10
done
```

### Input with Validation:

```bash
age=$(cal-tui::input_prompt "Enter your age:" true '^[0-9]+$' "Must be a number.")
echo "You are $age years old."
```

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 💡 Contributing

Pull requests and improvements welcome!

1. Fork the repo
2. Make your changes
3. Submit a PR

---

## 📦 Roadmap

* [ ] Arrow-key navigation menus

---

## 🤝 Acknowledgements

Made with ❤️ for Bash lovers and sysadmins everywhere.

