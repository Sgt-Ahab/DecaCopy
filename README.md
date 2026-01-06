# DecaCopy

DecaCopy is a lightweight Windows utility that provides **10 ephemeral clipboard registers (0–9)** alongside the native clipboard.

All data exists **only in memory** for the lifetime of the program.<br>  
No disk writes. No persistence. No telemetry.

---

## Design Philosophy

- Register-based workflow, not clipboard history
- Ephemeral state by design
- Keyboard-first, muscle-memory friendly
- Minimal surface area, easy to audit

---

## Hotkeys

### Save

- **Ctrl + Shift + C**  
  Open a menu to save the current selection into a slot (0–9).  
  Includes overwrite confirmation.

- **Ctrl + Shift + 0–9**  
  PowerSave: save the current selection directly into the specified slot  
  (no overwrite confirmation).

### Paste

- **Ctrl + Shift + V**  
  Open a menu to paste from a slot (0–9).

- **Ctrl + V**, then **0–9**  
  PowerPaste: paste directly from a slot if a number is entered.  
  If no slot is chosen, native paste occurs.

---

## Install

### Requirements

DecaCopy requires AutoHotkey v2 (64-bit).<br>
Download: [AHK2](https://www.autohotkey.com/v2/)

### Usage

Download `DecaCopy.ahk` and run it with AutoHotkey.

---

## License

This project is licensed under the MIT License.

You are free to use, modify, distribute, and fork this software, including for
commercial purposes, provided that the original copyright notice and license
are included.

See the `LICENSE` file for full details.



### Notes

**DecaCopy operates on text clipboard content only.**

*Run a single instance of DecaCopy at a time.*

**PowerSave** provides brief confirmation feedback by design.
Native paste may exhibit a slight delay, as it is intercepted intentionally.

**Slot capacity:** Each slot holds whatever the *Windows* clipboard can hold at runtime. Capacity is limited by available system memory.

**Slot 0:** In rare cases, slot 0 may conflict with native paste timing depending on the active application. 
            If issues occur, use slots 1–9 for critical workflows.

**Clipboard Restrictions: Some applications restrict clipboard access or simulated input; behavior may vary.**
