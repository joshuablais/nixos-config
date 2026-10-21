// ~/.config/sway/scripts/emacs-launcher.go
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// Sway criteria selectors atomically handle workspace switch + focus.
// app_id matches Wayland-native Emacs (pgtk); class matches XWayland.
// swaymsg exits 0 even when criteria matches nothing, so running both
// is safe and cheap.
func focusEmacs() {
	exec.Command("swaymsg", `[app_id="emacs"] focus`).Run()
	exec.Command("swaymsg", `[class="Emacs"] focus`).Run()
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: emacs-launcher <elisp-command>")
		fmt.Fprintln(os.Stderr, "example: emacs-launcher '(universal-launcher-popup)'")
		os.Exit(1)
	}
	elisp := strings.Join(os.Args[1:], " ")

	focusEmacs()

	if err := exec.Command("emacsclient", "-n", "-e", elisp).Run(); err != nil {
		fmt.Fprintf(os.Stderr, "emacsclient: %v\n", err)
		os.Exit(1)
	}
}
