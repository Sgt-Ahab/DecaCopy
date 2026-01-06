; DecaCopy v1.1.0
; 10 ephemeral clipboard registers (0–9) + native clipboard
; MenuSave warns on overwrite; PowerSave does not.
; No disk writes. No persistence. No telemetry.
#Requires AutoHotkey v2.0
#SingleInstance Force

isPasting := false
pasteMenu := 0
saveMenu := 0
menuSlotMap := Map()

slots := Map()
Loop 10
    slots[A_Index - 1] := ""

A_TrayMenu.Delete()
A_TrayMenu.Add("DecaCopy (Ephemeral)", (*) => "")
A_TrayMenu.Add("Exit", (*) => ExitApp())

^+c::MenuSave()
^+v::MenuPaste()

^+0::PowerSave(0)
^+1::PowerSave(1)
^+2::PowerSave(2)
^+3::PowerSave(3)
^+4::PowerSave(4)
^+5::PowerSave(5)
^+6::PowerSave(6)
^+7::PowerSave(7)
^+8::PowerSave(8)
^+9::PowerSave(9)

^v::PowerPaste()

PowerSave(slot) {
    global slots

    old := A_Clipboard
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(0.6) {
        A_Clipboard := old
        ToolTip "DecaCopy: nothing copied"
        SetTimer () => ToolTip(), -600
        return
    }

    slots[slot] := A_Clipboard
    A_Clipboard := old

    ToolTip "Saved to slot " slot
    SetTimer () => ToolTip(), -500
}

MenuSave() {
    global slots, saveMenu

    saveMenu := Menu()

    Loop 10 {
        i := A_Index - 1
        label := (slots[i] != "") ? ("Save to Slot " i " (overwrite)") : ("Save to Slot " i)
        saveMenu.Add(label, MenuSaveHandler)
    }

    saveMenu.Show()
}

MenuSaveHandler(ItemName, *) {
    global slots

    ; Extract first digit 0-9 from the menu text safely
    if !RegExMatch(ItemName, "(\d)", &m) {
        MsgBox "Could not determine slot from: " ItemName, "DecaCopy", "Iconx"
        return
    }

    slot := Integer(m[1])

    if slots.Has(slot) && slots[slot] != "" {
        result := MsgBox(
            "Overwrite Slot " slot " ?",
            "DecaCopy",
            "OKCancel Icon!"
        )
        if result != "OK"
            return
    }

    PowerSave(slot)
}

MenuPaste() {
    global slots, pasteMenu, menuSlotMap

    pasteMenu := Menu()
    menuSlotMap.Clear()

    Loop 10 {
        i := A_Index - 1
        if slots[i] != "" {
            label := "Paste Slot " i
            pasteMenu.Add(label, MenuPasteHandler)
            menuSlotMap[label] := i
        } else {
            pasteMenu.Add("Slot " i " (empty)", (*) => "")
        }
    }

    pasteMenu.Show()
}

MenuPasteHandler(ItemName, *) {
    global menuSlotMap
    slot := menuSlotMap[ItemName]
    PasteSlot(slot)
}

PasteSlot(slot) {
    global slots

    if slots[slot] = ""
        return

    old := A_Clipboard
    A_Clipboard := slots[slot]
    ClipWait 0.2
    NativePaste()
    Sleep 30
    A_Clipboard := old
}

PowerPaste() {
    global slots, isPasting

    if isPasting
        return

    isPasting := true
    try {
        ; Capture ONE key after Ctrl+V:
        ; - If it's a digit 0-9: paste slot and do NOT let the digit type into the app.
        ; - If it's anything else: fall through to native paste AND re-send that key.
        ; - If no key pressed in time: native paste.
        ih := InputHook("L1 T0.45")
        ih.KeyOpt("{All}", "S")  ; Suppress captured key so we can decide what to do with it
        ih.Start()
        ih.Wait()

        key := ih.Input  ; "" on timeout

        if (key != "" && key ~= "^[0-9]$") {
            slot := Integer(key)
            if slots.Has(slot) && slots[slot] != "" {
                PasteSlot(slot)
            } else {
                ; Slot empty -> behave like normal paste
                NativePaste()
            }
            return
        }

        ; No digit chosen (timeout OR non-digit):
        NativePaste()

        ; If user hit a non-digit key during the selection window, replay it after pasting.
        ; This prevents DecaCopy from "eating" the user's next keystroke.
        if (key != "") {
            Send "{Blind}" key
        }
    } finally {
        isPasting := false
    }
}

NativePaste() {
    ; Temporarily disable our Ctrl+V hook to prevent recursion
    Hotkey "^v", "Off"
    Send "{Blind}^v"
    Hotkey "^v", "On"
}
