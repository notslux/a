#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
version = 1.0
traytip, AintMissing %version%, AintMissing Has Been Loaded, 5, 1
Menu, tray, NoStandard
Menu, tray, Add
SetKeyDelay, -1, -1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
DllCall("QueryPerformanceFrequency", "Int64*", Update)
#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
SetKeyDelay, -1, -1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay, -1
SendMode, InputThenPlay
SetBatchLines, -1
ListLines, Off
CoordMode, Pixel, screen
PID := DllCall("GetCurrentProcessId")
Process, Priority, %PID%, High
DllCall("QueryPerformanceFrequency", "Int64*", Update)
class JSON
{
class Load extends JSON.Functor
{
Call(self, ByRef text, reviver:="")
{
this.rev := IsObject(reviver) ? reviver : false
this.keys := this.rev ? {} : false
static quot := Chr(34), bashq := "\" . quot
, json_value := quot . "{[01234567890-tfn"
, json_value_or_array_closing := quot . "{[]01234567890-tfn"
, object_key_or_object_closing := quot . "}"
key := ""
is_key := false
root := {}
stack := [root]
next := json_value
pos := 0
while ((ch := SubStr(text, ++pos, 1)) != "") {
if InStr(" `t`r`n", ch)
continue
if !InStr(next, ch, 1)
this.ParseError(next, text, pos)
holder := stack[1]
is_array := holder.IsArray
if InStr(",:", ch) {
next := (is_key := !is_array && ch == ",") ? quot : json_value
} else if InStr("}]", ch) {
ObjRemoveAt(stack, 1)
next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
} else {
if InStr("{[", ch) {
static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
(ch == "{")
? ( is_key := true
, value := {}
, next := object_key_or_object_closing )
: ( value := json_array ? new json_array : []
, next := json_value_or_array_closing )
ObjInsertAt(stack, 1, value)
if (this.keys)
this.keys[value] := []
} else {
if (ch == quot) {
i := pos
while (i := InStr(text, quot,, i+1)) {
value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
static tail := A_AhkVersion<"2" ? 0 : -1
if (SubStr(value, tail) != "\")
break
}
if (!i)
this.ParseError("'", text, pos)
value := StrReplace(value,  "\/",  "/")
, value := StrReplace(value, bashq, quot)
, value := StrReplace(value,  "\b", "`b")
, value := StrReplace(value,  "\f", "`f")
, value := StrReplace(value,  "\n", "`n")
, value := StrReplace(value,  "\r", "`r")
, value := StrReplace(value,  "\t", "`t")
pos := i
i := 0
while (i := InStr(value, "\",, i+1)) {
if !(SubStr(value, i+1, 1) == "u")
this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
uffff := Abs("0x" . SubStr(value, i+2, 4))
if (A_IsUnicode || uffff < 0x100)
value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
}
if (is_key) {
key := value, next := ":"
continue
}
} else {
value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
static number := "number", integer :="integer"
if value is %number%
{
if value is %integer%
value += 0
}
else if (value == "true" || value == "false")
value := %value% + 0
else if (value == "null")
value := ""
else
this.ParseError(next, text, pos, i)
pos += i-1
}
next := holder==root ? "" : is_array ? ",]" : ",}"
}
is_array? key := ObjPush(holder, value) : holder[key] := value
if (this.keys && this.keys.HasKey(holder))
this.keys[holder].Push(key)
}
}
return this.rev ? this.Walk(root, "") : root[""]
}
ParseError(expect, ByRef text, pos, len:=1)
{
static quot := Chr(34), qurly := quot . "}"
line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
,     (expect == "")     ? "Extra data"
: (expect == "'")    ? "Unterminated string starting at"
: (expect == "\")    ? "Invalid \escape"
: (expect == ":")    ? "Expecting ':' delimiter"
: (expect == quot)   ? "Expecting object key enclosed in double quotes"
: (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
: (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
: (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
: InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
:                      "Expecting JSON value(string, number, true, false, null, object or array)"
, line, col, pos)
static offset := A_AhkVersion<"2" ? -3 : -4
throw Exception(msg, offset, SubStr(text, pos, len))
}
Walk(holder, key)
{
value := holder[key]
if IsObject(value) {
for i, k in this.keys[value] {
v := this.Walk(value, k)
if (v != JSON.Undefined)
value[k] := v
else
ObjDelete(value, k)
}
}
return this.rev.Call(holder, key, value)
}
}
class Dump extends JSON.Functor
{
Call(self, value, replacer:="", space:="")
{
this.rep := IsObject(replacer) ? replacer : ""
this.gap := ""
if (space) {
static integer := "integer"
if space is %integer%
Loop, % ((n := Abs(space))>10 ? 10 : n)
this.gap .= " "
else
this.gap := SubStr(space, 1, 10)
this.indent := "`n"
}
return this.Str({"": value}, "")
}
Str(holder, key)
{
value := holder[key]
if (this.rep)
value := this.rep.Call(holder, key, ObjHasKey(holder, key) ? value : JSON.Undefined)
if IsObject(value) {
static type := A_AhkVersion<"2" ? "" : Func("Type")
if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
if (this.gap) {
stepback := this.indent
this.indent .= this.gap
}
is_array := value.IsArray
if (!is_array) {
for i in value
is_array := i == A_Index
until !is_array
}
str := ""
if (is_array) {
Loop, % value.Length() {
if (this.gap)
str .= this.indent
v := this.Str(value, A_Index)
str .= (v != "") ? v . "," : "null,"
}
} else {
colon := this.gap ? ": " : ":"
for k in value {
v := this.Str(value, k)
if (v != "") {
if (this.gap)
str .= this.indent
str .= this.Quote(k) . colon . v . ","
}
}
}
if (str != "") {
str := RTrim(str, ",")
if (this.gap)
str .= stepback
}
if (this.gap)
this.indent := stepback
return is_array ? "[" . str . "]" : "{" . str . "}"
}
} else
return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
}
Quote(string)
{
static quot := Chr(34), bashq := "\" . quot
if (string != "") {
string := StrReplace(string,  "\",  "\\")
, string := StrReplace(string, quot, bashq)
, string := StrReplace(string, "`b",  "\b")
, string := StrReplace(string, "`f",  "\f")
, string := StrReplace(string, "`n",  "\n")
, string := StrReplace(string, "`r",  "\r")
, string := StrReplace(string, "`t",  "\t")
static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
while RegExMatch(string, rx_escapable, m)
string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
}
return quot . string . quot
}
}
Undefined[]
{
get {
static empty := {}, vt_empty := ComObject(0, &empty, 1)
return vt_empty
}
}
class Functor
{
__Call(method, ByRef arg, args*)
{
if IsObject(method)
return (new this).Call(method, arg, args*)
else if (method == "")
return (new this).Call(arg, args*)
}
}
}
DllCall("QueryPerformanceFrequency", "Int64*", freq)
PlayerSearch := 1
SearchFor := 0xFDFDFC, 0x9D9B9B
DissectorX := 1,
DissectorY := 1,
Synchronization := 85
Lock_OnRate := 100000
X123 :=  100000
aim := 0
SmoothnessX := 1 / DissectorX,
SmoothnessY := 2/ DissectorY,
InterpolationX := 6.4,
InterpolationY := 6.6,
SegmentationX := 10,
SegmentationY := 10,
FOVOffsetX := 10,
FOVOffsetY := 10,
UseTargetOffsets := true
TargetOffsetX := 5,
TargetOffsetY := 5,
PerventAImingupX := 10,
PerventAImingupY := 10,
X := A_ScreenWidth
Y := A_ScreenHeight
WorldToScreenDivider := 2
ScreenSizeX := Floor(X // WorldToScreenDivider) - PerventAImingupX
ScreenSizeY := Floor(Y // WorldToScreenDivider) - PerventAImingupY
FOVOffsetX := fallback(FOVOffsetX, Synchronization, X, Y)
FOVOffsetY := fallback(FOVOffsetY, Synchronization, X, Y)
AimUP := ScreenSizeX - FOVOffsetX
AImDown := ScreenSizeY - FOVOffsetY
AimLeft := ScreenSizeX + FOVOffsetX
AimRight := ScreenSizeY + FOVOffsetY
Loop {
KeyWait, Rbutton, D
Position := SearchFor(AimUP, AImDown, AimLeft, AimRight, SearchFor, PlayerSearch)
if (!ErrorLevel) {
Start := Position[1]
End := Position[5]
FocusX := Position[1] - ScreenSizeX
IsPlayerJumping() {
return false
}
FocusY := Position[5] - ScreenSizeY
if (UseTargetOffsets) {
StopX := Floor(coordinatemode(FocusX + TargetOffsetX, Synchronization, A_ScreenWidth, A_ScreenHeight) * (SmoothnessX/SegmentationX) * InterpolationX)
StopY := Floor(coordinatemode(FocusY + TargetOffsetY, Synchronization, A_ScreenWidth, A_ScreenHeight) * (SmoothnessY/SegmentationY) * InterpolationY)
} else {
StopX := Floor(coordinatemode(FocusX, Synchronization, A_ScreenWidth, A_ScreenHeight) * (SmoothnessX/SegmentationX) * InterpolationX)
StopY := Floor(coordinatemode(FocusY, Synchronization, A_ScreenWidth, A_ScreenHeight) * (SmoothnessY/SegmentationY) * InterpolationY)
}
DllCall("QueryPerformanceCounter", "Int64*", DeltaTime)
if ((DeltaTime - aim) / Update * X123 >= 1000 / Lock_OnRate) {
DllCall("QueryPerformanceCounter", "Int64*", aim)
DllCall("mouse_event", "uint", 0x0001, "uint", StopX, "uint", StopY, "uint", 0x0001, "int", 0)
}
}
}
SearchFor(X1, Y1, X2, Y2, ColorIDs, Variation) {
PixelSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, ColorIDs, Variation, Fast RGB
Return [OutputVarX, OutputVarY]
}
degreetoradians(degrees) {
return degrees * ((4 * ATan(1)) / 175)
}
radianstodegrees(radians) {
return radians * (175 / (4 * ATan(1)))
}
coordinatemode(delta, fov, winWidth, winHeight) {
return radianstodegrees(atan(((delta << 1) / winWidth) * tan(degreetoradians(fov * 0.45))))
}
fallback(delta, fov, winWidth, winHeight) {
return winWidth * 0.45 / tan(degreetoradians(fov * 0.45)) * tan(degreetoradians(delta))
}
Return

F7::reload
insert::Exitapp