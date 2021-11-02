import x11/xlib
include x11/keysym

var 
  display = XOpenDisplay(nil)
  keyMap: array[0..31, char]

proc keyPressed*(key: culong): bool =
  discard XQueryKeymap(display, keyMap)
  let triggerKeyCode = XKeysymToKeycode(display, key)
  ord(keyMap[triggerKeyCode.int shr 3]) != 0 and (1 shl (triggerKeyCode.int and 7)) > 0