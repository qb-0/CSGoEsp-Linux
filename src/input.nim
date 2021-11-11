import os, x11/[xlib, xtst]
include x11/keysym

var display = XOpenDisplay(nil)

proc keyPressed*(key: KeySym): bool =
  var keys: array[0..31, char]
  discard XQueryKeymap(display, keys)
  let keycode = XKeysymToKeycode(display, key)
  (ord(keys[keycode.int div 8]) and (1 shl (keycode.int mod 8))) != 0

proc clickMouse* =
  discard XTestFakeButtonEvent(display, 1, 1, 0)
  discard XFlush(display)
  sleep(2)
  discard XTestFakeButtonEvent(display, 1, 0, 0)
  discard XFlush(display)