import x11/xlib
include x11/keysym

var 
  display = XOpenDisplay(nil)
  keyMap: array[0..31, char]

proc keyPressed*(key: culong): bool =
  discard XQueryKeymap(display, keyMap)
  var triggerKeyCode = XKeysymToKeycode(display, key)
  ord(keyMap[triggerKeyCode.uint div 8]) != 0 and (1 shl (triggerKeyCode.uint mod 8)) > 0