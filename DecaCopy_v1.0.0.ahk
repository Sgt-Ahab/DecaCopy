; DecaCopy v1.0.0
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

    ih := InputHook("L1 T0.45")
    ih.Start()
    ih.Wait()

    if ih.EndReason = "Max" {
        key := ih.Input
        if (key >= "0" && key <= "9") {
            slot := Integer(key)  ; convert string -> number (Map keys)
            if slots.Has(slot) && slots[slot] != "" {
                PasteSlot(slot)
                isPasting := false
                return
            }
        }
    }

    NativePaste()
    isPasting := false
}

NativePaste() {
    ; Temporarily disable our Ctrl+V hook
    Hotkey "^v", "Off"
    Send "^v"
    Hotkey "^v", "On"
}
