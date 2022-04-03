; #Requires AutoHotkey v1.1

; test := Object(0x10,"test1","0x100","test2")
; msgbox % test[0x10]
; exitapp

#INCLUDE TheArkive_Debug.ahk




test := Gui.New("+Resize","testing 1 2 3")

test.OnEvent("escape","gui_close")
test.OnEvent("close","gui_close")
test.OnEvent("size","gui_size")
test.OnEvent("contextmenu","gui_context")

test.BackColor := "blue"

ctl := test.add("text","vMyText","TEST TEXT TEST TEST TEST")
ctl.OnEvent("click","ctl_change")

ctl := test.Add("Edit","vMyEdit1","asdf asdf asdf asdf asdf asdf")
ctl.OnEvent("Losefocus","ctl_change")

ctl := test.Add("Edit","vMyEdit2")
ctl.OnEvent("LoseFocus","ctl_change")

ctl := test.Add("Button","vMyButton w200","Testing Button")
ctl.OnEvent("click","ctl_change")
ctl.Text := "Testing Button 2"

ctl := test.Add("ListBox","vMyListBox w200 h100",["ListBox1","ListBox2","ListBox3"])
ctl.OnEvent("change","ctl_change")
ctl.Value := 2

ctl := test.Add("DropDownList","vMyDropList w200",["DropList1","DropList2","DropList3"])
ctl.OnEvent("ContextMenu","context_menu")
ctl.value := 2

ctl := test.Add("ComboBox","vMyComboBox w200",["Combo1","Combo2","Combo3"])
ctl.OnEvent("change","ctl_change")
ctl.value := 2

ctl := test.Add("Edit","w200")
ctl := test.Add("UpDown","vMyUpDown w200",5)
ctl.OnEvent("change","ctl_change")

ctl := test.Add("Checkbox","vMyCheckbox","Test Checkbox")
ctl.OnEvent("change","ctl_change")
ctl.Value := 1

ctl := test.Add("Radio","vMyRadio1","Radio One")
ctl.OnEvent("change","ctl_change")
ctl := test.Add("Radio","vMyRadio2","Radio Two")
ctl.OnEvent("change","ctl_change")
ctl.Value := 1

ctl := test.Add("DateTime","vMyDateTime w200","LongDate")
ctl.OnEvent("LoseFocus","ctl_change")
ctl.Value := "16010512010203"

ctl := test.Add("MonthCal","vMyMonthCal Multi")
ctl.OnEvent("Change","ctl_change")

ctl := test.Add("Hotkey","vMyHotkey w200")
ctl.OnEvent("change","ctl_change")

ctl := test.Add("Link","vMyLink","This is a <a id=" Chr(34) "ABC" Chr(34) " href=" Chr(34) "https://www.autohotkey.com" Chr(34) ">link</a>")
ctl.OnEvent("Click","ctl_link")

hPic := LoadPicture("shell32.dll","Icon4 w128 h128",imgType)
ctl := test.Add("Picture","vMyPicture x300 ym w256 h256")
ctl.value := "HICON:" hPic
ctl.OnEvent("DoubleClick","ctl_change")

ctl := test.add("Progress","vMyProgress w200","50")
ctl.value := 75

ctl := test.add("Slider","vMySlider w200 Tooltip", "50")
ctl.OnEvent("change","ctl_change")
ctl.value := 75

tab := test.add("Tab3","vMyTab w200 h200",["Tab 1","Tab 2","Tab 3"])
tab.OnEvent("change","ctl_change")
tab.value := 2


; tab.UseTab(2)
; Gui, Tab, 2
test.add("Button","xp+50 yp+50","Tab Button 1")

tab.UseTab()

test.add("Button",,"Button after tab")

; tab.UseTab(3)
; test.add("Button","y+30","Tab Button 2")

test.Show("w600 h600")
Msgbox % tab.__GetItem(2)

; ControlGet, out_style, Style,, % txt.hwnd
; msgbox % "txt style: " Format("0x{:X}",out_style)


; msgbox % "menu handle: " MenuGetHandle("Tray")

test["MyEdit1"].Value := "test1"
test["MyEdit2"].Text := "test2"


; types := {CaptionFont:801, SmallCaptionFont:802, MenuFont:803, StatusFont:804, MsgBoxFont:805, IconTitleTextFont:806}
; n := GetThemeSysFont("Caption")
; msgbox % n.FaceName

; OnMessage(0x100,"my_test")
; my_test(wParam, lParam, msg, hwnd) {
    ; msgbox % "key code: " wParam
; }

; test["MyText"].Value := "TESTING 1 2 3"
; msgbox % "weird test: " test["big_test"]

; msgbox % "Text: " test["MyText"].Text "`r`nValue: " test["MyText"].Value "`r`nhwnd: " test["MyText"].hwnd

; ctl2 := test["MyText"]
; msgbox % "Text: " ctl2.Text "`r`nValue: " ctl2.Value "`r`nclass name: " ctl2.__Class "`r`nhwnd: " ctl2.hwnd
; ctl.Name := "MyText2"
; msgbox % "Value: " ctl.Text "`r`nName: " ctl.Name


; sleep, 3000
; test.Flash()
; sleep, 3000
; msgbox % "Hwnd hex: " Format("0x{:X}",test.hwnd) "`r`nHwnd dec: " test.hwnd

ctl_link(ctl, info, href) {
    dbg("Ctl name: " _ctl.name " / hwnd: " _ctl.hwnd " / info: " info " / href: " href)
}

context_menu(_ctl, Item, IsRightClick, X, Y) {
    dbg("control right click: "  " / x: " x " / y: " y " / ctl: " _ctl.name)
}

ctl_change(_ctl, info) {
    dbg("Ctl name: " _ctl.name " / hwnd: " _ctl.hwnd " / value: " _ctl.value)
}

gui_context(_gui, _ctl, Item, IsRightClick, X, Y) {
    dbg("r_click: " IsRightClick " / x: " x " / y: " y " / ctl: " _ctl.name)
}

gui_size(_gui, MinMax, w, h) {
    ; m := "MinMax: " MinMax " / w: " w " / h: " h " / x: "
    ; dbg("sizing: " m)
}

gui_close(_gui) {
    ExitApp
}

F12::ExitApp

class GuiControl {
    __hwnd := ""
    __ClassNN := ""
    __gui := ""
    __Name := ""
    on_events := Object()
    
    ius := (A_IsUnicode?2:1) ; string multiplier for Unicode / ANSI
    
    Static __WM_CMD_SET := false
    Static ActiveTab := [0,0,0]
    Static TabList := Object()
    
    __New(CtlType, Options, CtlName, Content, _gui, gui_hwnd) {
        If (CtlType = "Listbox"
        Or CtlType = "DropDownList"
        Or CtlType = "ComboBox"
        Or CtlType = "Tab3"
        Or CtlType = "Tab") {
            If (!Content.Length())
                throw Exception("Invalid content parameter.",,"ListBox content must be an array.")
            
            _content := Content
            Content := ""
            For i, val in _content
                Content .= ((i>1)?"|":"") val
        } Else If (CtlType = "Text")
            Options .= " +0x100" ; this doesn't seem to work
        Else If (CtlType = "Picture")
            Options .= " +0x3 +0xE +0x100"
        Else if (CtlType = "Slider")
            Options .= " +0x800"
        
        Gui, %gui_hwnd%:Add, %CtlType%, %Options%, %Content% ; __hwnd comes from options automatically
        
        this.__hwnd := Format("{:d}",__hwnd)
        this.__gui := _gui
        this.__Name := ctlName
        this.__ClassNN := this.__GetClassNN() ; thanks to teadrinker
        
        If (GuiControl.ActiveTab[1]) {
            pg_type := (GuiControl.ActiveTab[2] + 0) ? true : false ; true if number, false if text
            pg := GuiControl.ActiveTab[2]
            tab := this.gui[GuiControl.ActiveTab[1]]
            
            If (!pg_type) {
                pg_text := pg
                ex := GuiControl.ActiveTab[3] ; exact (true/false)
                n := tab.__GetCount()
                pg := 0
                Loop n {
                    If (tab.__GetItem(A_Index) ~= "i)^" pg_text (ex?"$":"")) {
                        this.__tab := [tab, n]
                        break
                    }
                }
                (!pg) ? (GuiControl.ActiveTab := [0,0,0]) : "" ; if invalid text specified, deactivate "current tab"
            } Else
                this.__tab := [tab, pg]
            
            
        }
        
        If (CtlType = "UpDown") {
            this.buddy := this.__sms(0x46A)
        } Else if (CtlType = "Tab3") Or (CtlType = "Tab") {
            GuiControl.TabList["_" this.hwnd] := Object()
        }
    }
    ClassNN[] {
        get {
            return this.__ClassNN
        }
    }
    Enabled[] {
        get {
            hwnd := this.hwnd
            GuiControlGet, result, Enabled, %hwnd%
            return result
        }
        set {
            hwnd := this.hwnd
            If value
                GuiControl, Enable, %hwnd%
            Else GuiControl, Disable, %hwnd%
        }
    }
    Focus() {
        hwnd := this.hwnd
        GuiControl, Focus, %hwnd%
    }
    GetPos(ByRef x, ByRef y, ByRef w, ByRef h) {
        
    }
    gui[] {
        get {
            return this.__gui
        }
    }
    hwnd[] {
        get {
            return this.__hwnd
        }
    }
    name[] {
        get {
            return this.__name
        }
        set {
            this.__name := value
        }
    }
    OnEvent(event_name, func_name) {
        
        If (this.__type = "Button" Or this.__type = "Checkbox" Or this.__Type = "Radio") {
            If (event_name = "Click") Or (event_name = "Change")
                this.on_events["_0x0000"] := func_name ; BN_CLICKED
            Else If (event_name = "DoubleClick")
                this.on_events["_0x0005"] := func_name ; BN_DBLCLK
            Else If (event_name = "Focus")
                this.on_events["_0x0006"] := func_name ; BN_SETFOCUS
            Else If (event_name = "LoseFocus")
                this.on_events["_0x0007"] := func_name ; BN_KILLFOCUS
            
        } Else If (this.__type = "ComboBox") Or (this.__type = "DropDownList") {
            If (event_name = "change")
                this.on_events["_0x0001"] := func_name ; CBN_SELCHANGE
            Else If (event_name = "DoubleClick")
                this.on_events["_0x0002"] := func_name ; CBN_DBLCLK
            Else if (event_name = "Focus")
                this.on_events["_0x0003"] := func_name ; CBN_SETFOCUS
            Else If (event_name = "LoseFocus")
                this.on_events["_0x0004"] := func_name ; CBN_KILLFOCUS
        
        } Else If (this.__type = "DateTime") {
            If (event_name = "change")
                this.on_events["_-759"] := func_name ; DTN_DATETIMECHANGE
            Else If (event_name = "Focus")
                this.on_events["_-7"] := func_name ; NM_SETFOCUS
            Else If (event_name = "LoseFocus")
                this.on_events["_-8"] := func_name ; NM_KILLFOCUS
            
        } Else If (this.__type = "Edit") or (this.__type = "Hotkey") {
            If (event_name = "change")
                this.on_events["_0x0300"] := func_name ; EN_CHANGE
            Else If (event_name = "focus")
                this.on_events["_0x0100"] := func_name ; EN_SETFOCUS
            Else If (event_name = "LoseFocus")
                this.on_events["_0x0200"] := func_name ; EN_KILLFOCUS
        
        } Else If (this.__type = "Link") {
            If (event_name = "Click")
                this.on_events["_-2"] := func_name
            
        } Else if (this.__type = "ListBox") {
            If (event_name = "change")
                this.on_events["_0x0001"] := func_name ; LBN_SELCHANGE
            Else If (event_name = "DoubleClick")
                this.on_events["_0x0002"] := func_name ; LBN_DBLCLK
            Else If (event_name = "focus")
                this.on_events["_0x0004"] := func_name ; LBN_SETFOCUS
            Else If (event_name = "LoseFocus")
                this.on_events["_0x0005"] := func_name ; LBN_KILLFOCUS
        
        } Else if (this.__type = "MonthCal") {
            If (event_name = "change")
                this.on_events["_-749"] := func_name
        
        } Else If (this.__type = "Slider") {
            If (event_name = "Change")
                this.on_events["_-1502"] := func_name ; TRBN_THUMBPOSCHANGING
        
        } Else If (this.__type = "Tab3") Or (this.__type = "Tab") {
            If (event_name = "Change")
                this.on_events["_-551"] := func_name ; TCN_SELCHANGE
        
        } Else If (this.__type = "Text") Or (this.__type = "Picture") {
            If (event_name = "Click")
                this.on_events["_0x0000"] := func_name ; STN_CLICKED
            Else If (event_name = "DoubleClick")
                this.on_events["_0x0001"] := func_name ; STN_DBLCLK
        
        } Else If (this.__type = "UpDown") {
            If (event_name = "Change")
                this.on_events["_-722"] := func_name ; UDN_DELTAPOS
        }
        
        If (event_name = "ContextMenu")         ; ContextMenu event for any control
            this.on_events["_0x9999"] := func_name     ; ... not a real control event.
                                                       ; Synthesized in main window events.
        this.RegisterEventHandlers()
    }
    OnNotify(event_name, func_name) {
        
        this.RegisterEventHandlers()
    }
    OnEventHandler(wParam, lParam, wm_msg, hwnd) {
        ctl_hwnd := lParam
        _msg := "_" Format("0x{:04X}",(msg := wParam >> 16))
        
        dbg("in: hwnd: " ctl_hwnd " / " this.gui.ctl_list[ctl_hwnd].name " / " _msg)
        
        If (ctl := this.gui.ctl_list[ctl_hwnd]) {
            cb := ctl.on_events[_msg]
            
            ; dbg("WMC ctl: " ctl.Name " / cb: " cb " / msg: " _msg " / wm_msg: " wm_msg)
            
            If (((msg = 0x300)  ; EN_CHANGE
            Or (msg = 0x200)    ; EN_KILLFOCUS
            Or (msg = 0x100)    ; EN_SETFOCUS
            Or (msg = 0x114)
            Or (msg = 0x115)
            Or (msg>=0 And msg<=7)) ; other events for other controls
            And (cb))
                result := %cb%(ctl, "")
        }
        return 0
    }
    OnNotifyHandler(wParam, lParam, msg, hwnd) {
        ctl_hwnd := NumGet(lParam+0,"UPtr")
        _msg := "_" (msg := (NumGet(lParam+(A_PtrSize*2),"UPtr") << 32 >> 32))
        
        dbg("WM_NOTIFY: hwnd: " ctl_hwnd " / " this.gui.ctl_list[ctl_hwnd].name " / " _msg)
        
        If (ctl := this.gui.ctl_list[ctl_hwnd]) {
            cb := ctl.on_events[_msg]
            
            ; dbg("WMN ctl: " ctl.Name " / cb: " cb " / msg: " _msg)
            
            If (ctl.__type = "UpDown") {
                iPos := NumGet(lParam+(A_PtrSize*3),"Int")
                iDelta := NumGet(lParam+(A_PtrSize*3)+4,"Int")
                ctl.__NewValue := iPos + iDelta
            } Else If (ctl.__type = "Link") {
                mask := NumGet(lParam+(A_PtrSize*3),"UInt")
                iLink := NumGet(lParam+(A_PtrSize*3)+4,"Int")
                state := NumGet(lParam+(A_PtrSize*3)+8,"UInt")
                stateMask := NumGet(lParam+(A_PtrSize*3)+12,"UInt")
                
                id := StrGet(lParam+(A_PtrSize*3)+16,48)
                link := StrGet(lParam+(A_PtrSize*3)+16+(48*this.ius),2048 + 32 + 3)
            }
            
            If ((msg = -722)    ; UDN_DELTAPOS = -722 / NM_RELEASEDCAPTURE = -16
            Or (msg = -1502)    ; TRBN_THUMBPOSCHANGING
            Or (msg = -759)     ; DTN_DATETIMECHANGE
            Or (msg = -749)     ; MCN_SELCHANGE
            Or (msg = -551)     ; TCN_SELCHANGE
            Or (msg = -7)       ; NM_SETFOCUS
            Or (msg = -8)       ; NM_KILLFOCUS
            Or (msg = -2)       ; NM_CLICK (Link)
            And (cb)) {
                If (ctl.__type = "Link")
                    result := %cb%(ctl, id, link) ; only link events
                Else
                    result := %cb%(ctl, "") ; all other WM_NOTIFY events
            }
        }
        return 0
    }
    Opt(_in) {
        GuiControl, %_in%, % this.hwnd
    }
    RegisterEventHandlers() {
        If (!GuiControl.__WM_CMD_SET) { ; Do this only once!
            _wm_command := ObjBindMethod(this,"OnEventHandler") ; only bind when needed
            _wm_notify := ObjBindMethod(this,"OnNotifyHandler")
            
            OnMessage(0x111,_wm_command)
            OnMessage(0x4E,_wm_notify)
            GuiControl.__WM_CMD_SET := true
        }
    }
    Text[] {
        get {
            return this.__GetText()
        }
        set {
            this.__SetText(value)
        }
    }
    type[] {
        get {
            return this.__Class
        }
    }
    __type[] {
        get {
            return StrReplace(StrReplace(this.__Class,"GuiControl.",""),"_","")
        }
    }
    Value[] {
        get {
            return this.__GetValue()
        }
        set {
            result := this.__SetValue(value)
        }
    }
    Visible[] {
        get {
            hwnd := this.hwnd
            GuiControlGet, result, Visible, %hwnd%
            return result
        }
        set {
            hwnd := this.hwnd
            If value
                GuiControl, Show, %hwnd%
            Else GuiControl, Hide, %hwnd%
        }
    }
    
    __GetClassNN() { ; thanks to SKAN /// Link: https://www.autohotkey.com/boards/viewtopic.php?p=358244#p358244
        Local   hWnd := "", NN := "", Class, hPar
        WinGetClass, Class, % "ahk_id " this.hwnd
        If ( (hPar := DllCall("GetAncestor", "Ptr",this.hwnd, "Int",2, "Ptr")) != this.hwnd )  ; GA_ROOT
            While ( hWnd!=0 && hWnd!=this.hwnd )
                hWnd := DllCall("FindWindowEx", "Ptr",hPar, "Ptr",hWnd, "Str",Class, "Ptr",0, "Ptr")
              , NN := A_Index
        Return hWnd ? (Class . NN) : ""
    }
    
    __GetCount() { ; for ListBox / ComboBox / DropDownList / Tab-Tab3
        If (this.__type = "ComboBox" Or this.__type = "DropDownList")
            return this.__sms(0x146)
        Else If (this.__type = "ListBox")
            return this.__sms(0x18B)
        Else If (this.__type = "Tab3" Or this.__type = "Tab")
            return this.__sms(0x1304)
        Else
            return 0
    }
    
; typedef struct tagTCITEMA {offset|size
  ; UINT   mask;            |0      4
  ; DWORD  dwState;         |4      8
  ; DWORD  dwStateMask;     |8      12
  ; LPSTR  pszText;         |12/16  16/24
  ; int    cchTextMax;      |16/24  20/28
  ; int    iImage;          |20/28  24/32
  ; LPARAM lParam;          |24/32  28/40
; } TCITEMA, *LPTCITEMA;
    
    __GetItem(_in) { ; get items text --- for ListBox / ComboBox / DropDownList / Tab-Tab3
        If (_in<1)
            return
        
        If ((t := this.__type) = "Tab" Or t = "Tab3") {
            VarSetCapacity(TCITEM, 32, 0) ; 40:28 ; full size
            VarSetCapacity(txt_buf, 64, 0)
            NumPut(1, &TCITEM, "UInt") ; number, var, offset, type
            NumPut(&txt_buf, &TCITEM+8+A_PtrSize, "UPtr")
            NumPut(64, &TCITEM+8+(A_PtrSize*2), "Int")
            result := this.__sms((A_Is64bitOS?0x133C:0x1305), _in-1, &TCITEM)
            
            lpsz := NumGet(&TCITEM,8+A_PtrSize,"UPtr")
            out_str := StrGet(lpsz)
            
        } Else { ; ListBox / ComboBox / DropDownList
            msg := (t = "Listbox") ? 0x18A : 0x149 ; LB_GETTEXTLEN / CB_GETLBTEXTLEN
            len := this.__sms(msg,_in-1)
            VarSetCapacity(str, (len+1) * this.ius, 0)
            
            msg := (t = "ListBox") ? 0x189 : 0x148 ; LB_GETTEXT / CB_GETLBTEXT
            len2 := this.__sms(msg, _in-1, &str)
            out_str := StrGet(&str)
        }
        
        return out_str
    }
    __GetText() { ; for controls that are NOT multi-select capable (or shouldn't be)
        If (this.__type = "Button" Or this.__type = "Text" Or this.__type = "Checkbox" Or this.__type = "Radio"
        Or this.__type = "Edit" Or this.__type = "ComboBox" Or this.__type = "DropDownList") {
            len := DllCall("User32\GetWindowTextLength", "UPtr", this.hwnd)
            VarSetCapacity(win_text, (len+1) * this.ius, 0)
            out_len := DllCall("User32\GetWindowText", "UPtr", this.hwnd, "Str", win_text, "Int", len+1)
            return win_text
        } Else If (this.__type = "ListBox") {
            idx := this.__GetValue()
            return this.__GetItem(idx)
        }
    }
    __SetText(_in) {
        If (this.__type = "Button" Or this.__type = "Text" Or this.__type = "Checkbox" Or this.__type = "Radio" Or this.__type = "Edit") {
            result := DllCall("User32\SetWindowText", "UPtr", this.hwnd, "Str", _in)
            return result
        }
    }
    
    
    __GetValue() {
        ; dbg("getting value: " this.__type)
        
        If (this.__type = "Button")
            result := this.__GetText()
        Else if (this.__type = "Checkbox" Or this.__type = "Radio")
            result := this.__sms(0xF0)
        Else If (this.__type = "ComboBox" Or this.__type = "DropDownList")
            result := this.__sms(0x147)+1 ; CB_GETCURSEL
        Else if (this.__type = "DateTime") {
            VarSetCapacity(SYSTIME, 16, 0)
            this.__sms(0x1001,0,&SYSTIME)
            
            yr := Format("{:02d}",NumGet(SYSTIME,"UShort"))
            mo := Format("{:02d}",NumGet(SYSTIME,2,"UShort"))
            dy := Format("{:02d}",NumGet(SYSTIME,6,"UShort"))
            hr := Format("{:02d}",NumGet(SYSTIME,8,"UShort"))
            mm := Format("{:02d}",NumGet(SYSTIME,10,"UShort"))
            ss := Format("{:02d}",NumGet(SYSTIME,12,"UShort"))
            
            return yr mo dy hr mm ss
        } Else If (this.__type = "Edit")
            result := this.__GetText()
        Else if (this.__type = "Hotkey")
            GuiControlGet, result,, % this.hwnd
        Else If (this.__type = "ListBox")
            result := this.__sms(0x188)+1 ; LB_GETCURSEL
        Else If (this.__type = "MonthCal")
            GuiControlGet, result,, % this.hwnd
        Else If (this.__type = "Picture")
            GuiControlGet, result,, % this.hwnd
        Else If (this.__type = "Progress")
            GuiControlGet, result,, % this.hwnd
        Else If (this.__type = "Radio")
            result := this.__sms()
        Else if (this.__type = "Slider")
            GuiControlGet, result,, % this.hwnd
        Else If (this.__type = "Tab3")
            result := this.__sms(0x130B)+1
        Else If (this.__type = "Text")
            result := this.__GetText()
        Else If (this.__type = "UpDown")
            result := this.__NewValue
        Else
            result := ""
        
        return result
    }
    __SetValue(_in) {
        If (this.__type = "Button")
            throw Exception("This control does not accept a value.",,"Invalid control: " this.__type)
        Else If (this.__type = "Checkbox" or this.__type = "Radio")
            result := this.__sms(0xF1,_in)
        Else If (this.__type = "ComboBox" Or this.__type = "DropDownList")
            result := this.__sms(0x14E,_in-1) ; CB_SETCURSEL
        ELse If (this.__type = "DateTime") {
            If (_in="") {
                this.__sms(0x1002,1)
                return
            }
            
            VarSetCapacity(SYSTIME, 16, 0)
            NumPut(SubStr(_in,1,4),SYSTIME,0,"UShort") ; yr num, var, offset, type
            NumPut(SubStr(_in,5,2),SYSTIME,2,"UShort") ; mo
            NumPut(SubStr(_in,7,2),SYSTIME,6,"UShort") ; dy
            NumPut(SubStr(_in,9,2),SYSTIME,8,"UShort") ; hr
            NumPut(SubStr(_in,11,2),SYSTIME,10,"UShort") ; mm
            NumPut(SubStr(_in,13,2),SYSTIME,12,"UShort") ; ss
            
            result := this.__sms(0x1002,0,&SYSTIME)
        } Else If (this.__type = "Edit")
            result := this.__SetText(_in)
        Else If (this.__type = "Hotkey")
            GuiControl,, % this.hwnd, % _in
        Else If (this.__type = "ListBox")
            result := this.__sms(0x186,_in-1) ; LB_SETCURSEL
        Else if (this.__type = "MonthCal")
            GuiControl,, % this.hwnd, % _in
        Else If (this.__type = "Picture")
            GuiControl,, % this.hwnd, % _in
        Else if (this.__type = "Progress")
            GuiControl,, % this.hwnd, % _in
        Else If (this.__type = "Radio")
            result := this.__sms()
        Else If (this.__type = "Slider")
            GuiControl,, % this.hwnd, % _in
        Else If (this.__type = "Tab3")
            result := this.__sms(0x130C,_in-1)
        Else If (this.__type = "Text")
            result := this.__GetText()
        Else
            result := ""
        
        return result
    }
    __sms(Msg, wParam:=0, lParam:=0) {
        SendMessage %Msg%, %wParam%, %lParam%, , % "ahk_id " this.hwnd
        if (ErrorLevel = "FAIL")
            return := ""
        Else return ErrorLevel
    }
    
    
    class Button extends GuiControl { ; 0, 5, 6, 7

    }
    
    class Checkbox extends GuiControl {

    }
    
    class ComboBox extends GuiControl {

    }
    
    class DateTime extends GuiControl {

    }
    
    class DropDownList extends GuiControl {

    }
    
    class Edit extends GuiControl {

    }
    
    class Hotkey extends GuiControl {
    
    }
    
    class Link extends GuiControl {
    
    }
    
    class ListBox extends GuiControl {

    }
    
    class MonthCal extends GuiControl {
    
    }
    
    class Picture extends GuiControl {
    
    }
    
    class Progress extends GuiControl {
    
    }
    
    class Radio extends GuiControl {

    }
    
    class Slider extends GuiControl {
    
    }
    
    class Tab3 extends GuiControl {
        UseTab(p1:=0,p2:=false) {
            GuiControl.ActiveTab := [p1?this.hwnd:0,p1,p2] ; tab hwnd / tab page / exact (true/false)
        }
    }
    
    class _Text extends GuiControl {

    }
    
    class UpDown extends GuiControl {

    }
}

class Gui {
    _hwnd := 0
    ctl_list := Object()
    caption_H := 0, border_W := 0, border_H := 0
    events_cb := Object("_0x0112",""    ; WM_SYSCOMMAND ; intercepts close event
                      , "_0x0100",""    ; WM_KEYDOWN (escape)
                      , "_0x0214",""    ; WM_SIZING (size)
                      , "_0x0216",""    ; WM_MOVING (size)
                      , "_0x007B",""    ; WM_CONTEXTMENU (contextMenu)
                      , "_0x0205","")   ; WM_RBUTTONUP (contextMenu)
    _BackColor := ""
    _MarginX := ""
    _MarginY := ""
    
    ; should be static
    Static __WM_CMD_SET := false
    Static right_click := false
    Static win_list := Object()
    
    __New(Options := "", Title := "") {
        Gui, New, % Options, % Title                    ; Get initial Margin values.
        hwnd := Format("{:d}",NewGuiHwnd)
        Gui, Add, Text, Hwnd__Hwnd, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        GuiControlGet, dims, Pos, %__Hwnd%
        this._MarginX := dimsX, this._MarginY := dimsY  ; Populate initial Margin values.
        
        _style := DllCall("GetWindowLongPtr","Ptr",NewGuiHwnd,"Int",-16,"UInt") ; get style
        If !(_style & 0x40000) {
            SysGet, border1_W, 7  ; not sizeable
            SysGet, border1_H, 8
        } Else {
            SysGet, border1_W, 32 ; sizeable
            SysGet, border1_H, 33
        }
        SysGet, cap_H, 4 ; caption height
        
        this.border_W := border1_W          ; Win border on X axis.
        this.border_H := border1_H + cap_H  ; Win border on top including caption bar.
        Gui, %NewGuiHwnd%:Destroy
        
        Gui, New, % Options, % Title
        this._hwnd := Format("{:d}",NewGuiHwnd)
        Gui.win_list[NewGuiHwnd] := true ; record window in global list, apart from windows not created with this method
    }
    __Delete() {
        hwnd := this._hwnd
        Gui, %hwnd%:Destroy
    }
    __Get(key) {
        If (key="BackColor")
            return this._BackColor
        Else If (key="hwnd")
            return this._hwnd
        Else If (key="MarginX")
            return this._MarginX
        Else If (key="MarginY")
            return this._MarginY
        
        For hwnd, ctl in this.ctl_list
            If ctl.Name = key
                return ctl
    }
    Add(CtlType, Options := "", Content := "") {
        hwnd := this._hwnd, Options .= " Hwnd__hwnd"
        
        a := StrSplit(Options," "), CtlName := "", Options := ""
        For i, val in a {
            If val ~= "i)^v\w+"
                CtlName := SubStr(val,2)
            Else Options .= val " "
        }
        
        params := [CtlType, Options, CtlName, Content, this, this._hwnd]
        If (CtlType = "Button")
            _ctl := New GuiControl.Button(params*)
        Else if (CtlType = "Checkbox")
            _ctl := New GuiControl.Checkbox(params*)
        Else If (CtlType = "ComboBox")
            _ctl := New GuiControl.ComboBox(params*)
        Else If (CtlType = "DateTime")
            _ctl := New GuiControl.DateTime(params*)
        Else If (CtlType = "DropDownList")
            _ctl := New GuiControl.DropDownList(params*)
        Else If (CtlType = "Edit")
            _ctl := New GuiControl.Edit(params*)
        Else If (CtlType = "Hotkey")
            _ctl := New GuiControl.Hotkey(params*)
        Else if (CtlType = "Link")
            _ctl := New GuiControl.Link(params*)
        Else If (CtlType = "ListBox")
            _ctl := New GuiControl.ListBox(params*)
        Else if (CtlType = "MonthCal")
            _ctl := New GuiControl.MonthCal(params*)
        Else if (CtlType = "Picture")
            _ctl := New GuiControl.Picture(params*)
        Else If (CtlType = "Progress")
            _ctl := New GuiControl.Progress(params*)
        Else If (CtlType = "Radio")
            _ctl := New GuiControl.Radio(params*)
        Else If (CtlType = "Slider")
            _ctl := New GuiControl.Slider(params*)
        Else if (CtlType = "Tab3") Or (CtlType = "Tab")
            _ctl := New GuiControl.Tab3(params*)
        Else If (CtlType = "Text")
            _ctl := New GuiControl._Text(params*)
        Else If (CtlType = "UpDown")
            _ctl := New GuiControl.UpDown(params*)
        Else
            throw Exception("Invalid control type specified.")
        
        this.ctl_list[_ctl.hwnd] := _ctl
        return _ctl
    }
    Destroy() {
        hwnd := this._hwnd, this._hwnd := 0
        Gui, %hwnd%:Destroy
    }
    Flash(Blink := true) {
        hwnd := this._hwnd
        If Blink
            Gui, %hwnd%:Flash
        Else Gui, %hwnd%:Flash, Off
    }
    Hide() {
        hwnd := this._hwnd
        Gui, %hwnd%:Hide
    }
    Maximize(hwnd) {
        hwnd := (!hwnd?this._hwnd:hwnd)
        Gui, %hwnd%:Maximize
        return 1
    }
    Minimize(hwnd) {
        hwnd := (!hwnd?this._hwnd:hwnd)
        Gui, %hwnd%:Minimize
        return -1
    }
    New(Options := "", Title := "") {
        return New Gui(Options " +HwndNewGuiHwnd" ,Title)
    }
    OnEvent(event_name, func_name) {
        _handler := ObjBindMethod(this,"OnEventHandler") ; only bind when needed
        
        If (event_name = "close") {
            this.events_cb["_0x0112"] := func_name ; WM_SYSCOMMAND
        } Else If (event_name = "escape") {
            this.events_cb["_0x0100"] := func_name ; WM_KEYDOWN - for ESC only
        } Else If (event_name = "size") {
            this.events_cb["_0x0214"] := func_name ; WM_SIZING
            this.events_cb["_0x0216"] := func_name ; WM_MOVING
        } Else If (event_name = "contextmenu") {
            this.events_cb["_0x007B"] := func_name ; WM_CONTEXTMENU
            this.events_cb["_0x0205"] := func_name ; WM_RBUTTONUP
        }
        
        If !Gui.__WM_CMD_SET {       ; Only do this once!
            OnMessage(0x112,_handler) ; WM_SYSCOMMAND
            
            OnMessage(0x100,_handler) ; WM_KEYDOWN - for ESC only
            
            OnMessage(0x214,_handler) ; WM_SIZING
            OnMessage(0x216,_handler) ; WM_MOVING
        
            OnMessage(0x07B,_handler) ; WM_CONTEXTMENU
            OnMessage(0x205,_handler) ; WM_RBUTTONUP
            Gui.__WM_CMD_SET := true
        }
    }
    OnEventHandler(wParam, lParam, msg, hwnd) {
        ; DebugMsg(wParam " / " lParam " / " Format("0x{:04X}",msg))
        
        _msg := "_" Format("0x{:04X}",msg)
        hPar := (Gui.win_list[hwnd]) ? hwnd : DllCall("GetAncestor", "Ptr",hwnd, "Int",2, "Ptr")
        do_win := Gui.win_list[hPar]
        
        ; dbg(wParam " / " lParam " / " _msg " / do_win: " do_win)
        
        If (msg = 0x112) And (wParam = 0xF060) { ; "close event" (technically hide event)
            cb := this.events_cb[_msg]
            
            If (cb and do_win)
                result := %cb%(this)
            
            If (!cb or !result)
                WinHide, % "ahk_id " hwnd
            Else If (result)
                return 0 ; halt window hide
        } Else If (msg = 0x112) And (wParam = 0xF030 Or wParam = 0xF020 Or wParam = 0xF120) { ; modified "sizing" event (aka min/max/restore)
            MinMax := 0
            
            If (wParam = 0xF030) ; maximize
                MinMax := this.Maximize(hwnd)
            Else If (wParam = 0xF120) ; restore
                MinMax := this.Restore(hwnd)
            Else If (wParam = 0xF020) ; minimize
                MinMax := this.Minimize(hwnd)
            
            WinGetPos,,,w,h, % "ahk_id " this._hwnd
            cb := this.events_cb["_0x0214"] ; force get callback for sizing/moving
            
            If (cb and do_win)
                result := %cb%(this, MinMax, w, h)
            
            return 0
        } Else If (msg = 0x100) And (wParam = 27) { ; "escape" event
            cb := this.events_cb[_msg]
            
            If (cb And do_win)
                result := %cb%(this)
            
        } Else If (msg = 0x214) Or (msg = 0x216) { ; Sizing event - L T R B
            X := NumGet(lParam+0 ,"UInt") << 32 >> 32 ; Conversion for negative numbers...
            Y := NumGet(lParam+4 ,"UInt") << 32 >> 32 ; ... doesn't affect positive numbers.
            W := NumGet(lParam+8 ,"UInt") - X
            H := NumGet(lParam+12,"UInt") - Y
            
            cb := this.events_cb[_msg]
            
            If (cb And do_win)
                result := %cb%(this, 0, w, h)
        } Else If (msg = 0x07B) { ; WM_CONTEXTMENU ; GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y
            
            ctl := (this.ctl_list.HasKey(hwnd)) ? this.ctl_list[hwnd] : ""
            MouseGetPos _Mx, _My, win_hwnd, ctl_hwnd, 2
            
            If (this.hwnd = win_hwnd And ctl_hwnd) {
                ctl := this.ctl_list[ctl_hwnd]
                cb2 := ctl.on_events["_0x9999"]
                
                If (cb2) {
                    _item := -1
                    %cb2%(ctl, _item, Gui.right_click, _Mx, _My)
                    Gui.right_click := false
                    
                    return
                }
            }
            
            If (!cb Or !do_win)
                return 0
            
            WinGetPos win_x, win_y, win_w, win_h, % "ahk_id " this._hwnd
            
            new_X := (lParam & 0xFFFF) - win_x - this.border_W
            new_Y := (lParam >> 16) - win_y - this.border_H
            
            cb := this.events_cb[_msg]
            
            If (!Gui.right_click And y=-1 And x=65535) Or (Gui.right_click)
                result := %cb%(this, ctl, Item, Gui.right_click, new_x, new_y)
            
            Gui.right_click := false
        } Else If (msg = 0x205) { ; WM_RBUTTONUP
            Gui.right_click := true
        }
    }
    OnNotify(event_name, func_name) {
        
    }
    Restore(hwnd:=0) {
        hwnd := (!hwnd?this._hwnd:hwnd)
        Gui, %hwnd%:Restore
        return 0
    }
    SetFont(Options := "", FontName := "") {
        hwnd := this._hwnd
        Gui, %hwnd%:Font, % Options, % FontName
    }
    Show(Options := "", Title := "") {
        hwnd := this._hwnd
        Gui, %hwnd%:Show, % Options, % Title
    }
    
    
    BackColor[] {
        set {
            hwnd := this._hwnd
            this._BackColor := value
            Gui %hwnd%:Color, %value%
        }
    }
    MarginX[] {
        set {
            hwnd := this._hwnd
            this._MarginX := value
            Gui, %hwnd%:Margin, %value%
        }
    }
    MarginY[] {
        set {
            hwnd := this._hwnd
            this._MarginY := value
            Gui, %hwnd%:Margin, , %value%
        }
    }
}









Edit()
{
    Edit
}

FileAppend(Text:="", Filename:="", Encoding:="")
{
    FileAppend %Text%, %Filename%, %Encoding%
    return !ErrorLevel
}

PostMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    PostMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (ErrorLevel = "FAIL")
        ErrorLevel := ""
}

RegDeleteKey(RootKeySubKey)
{
    RegDelete %RootKeySubKey%
    return !ErrorLevel
}

SendMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:="")
{
    SendMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%, %Timeout%
    if (ErrorLevel = "FAIL")
        return := ""
    Else return ErrorLevel
}

dbg(_in) {
    OutputDebug AHK: %_in%
}