import x11/[xlib, xtst]
include x11/keysym

var 
  display = XOpenDisplay(nil)
  keyMap: array[0..31, char]

proc keyPressed*(key: culong): bool =
  discard XQueryKeymap(display, keyMap)
  let triggerKeyCode = XKeysymToKeycode(display, key)
  ord(keyMap[triggerKeyCode.int shr 3]) != 0 and (1 shl (triggerKeyCode.int and 7)) > 0

proc clickMouse* =
  discard XTestFakeButtonEvent(display, 1, 1, 0)
  discard XFlush(display)
  discard XTestFakeButtonEvent(display, 1, 0, 0)
  discard XFlush(display)