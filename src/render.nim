import strutils, math, colors, osproc
import nimgl/[glfw, opengl]
import opengl/glut

type
  Overlay* = object
    width*, height*, midX*, midY*: int32
    hwnd*: int
    videoMode*: ptr GLFWVidMode
    window*: GLFWWindow

  Vector2D* = object
    x*, y*: float32
  Vector3D* = object
    x*, y*, z*: float32
  Vector4D* = object
    x*, y*, z*, w*: float32

  WinInfo = tuple
    upperX, upperY, width, height: int32

#[
  vector
]#

proc Vector*(x: float32, y: float32): Vector2D =
  Vector2D(x: x, y: y)
proc Vector*(x: float32, y: float32, z: float32): Vector3D =
  Vector3D(x: x, y: y, z: z)

proc `+`*(self: Vector2D, v: Vector2D): Vector2D =
  Vector2D(x: self.x + v.x, y: self.y + v.y)
proc `+`*(self: Vector3D, v: Vector3D): Vector3D =
  Vector3D(x: self.x + v.x, y: self.y + v.y, z: self.z + v.z)
proc `+`*(self: Vector2D, v: float32): Vector2D =
  Vector2D(x: self.x + v, y: self.y + v)
proc `+`*(self: Vector3D, v: float32): Vector3D =
  Vector3D(x: self.x + v, y: self.y + v, z: self.z + v)

proc `+=`*(self: var Vector2D, v: float32) =
  self.x = self.x + v
  self.y = self.y + v
proc `+=`*(self: var Vector3D, v: float32) =
  self.x = self.x + v
  self.y = self.y + v
  self.z = self.z + v
proc `+=`*(self: var Vector2D, v: Vector2D) =
  self.x = self.x + v.x
  self.y = self.y + v.y
proc `+=`*(self: var Vector3D, v: Vector3D) =
  self.x = self.x + v.x
  self.y = self.y + v.y
  self.z = self.z + v.z

proc `-`*(self: Vector2D, v: Vector2D): Vector2D =
  Vector2D(x: self.x - v.x, y: self.y - v.y)
proc `-`*(self: Vector3D, v: Vector3D): Vector3D =
  Vector3D(x: self.x - v.x, y: self.y - v.y, z: self.z - v.z)
proc `-`*(self: Vector2D, v: float32): Vector2D =
  Vector2D(x: self.x - v, y: self.y - v)
proc `-`*(self: Vector3D, v: float32): Vector3D =
  Vector3D(x: self.x - v, y: self.y - v, z: self.z - v)

proc `-=`*(self: var Vector2D, v: float32) =
  self.x = self.x - v
  self.y = self.y - v
proc `-=`*(self: var Vector3D, v: float32) =
  self.x = self.x - v
  self.y = self.y - v
  self.z = self.z - v
proc `-=`*(self: var Vector2D, v: Vector2D) =
  self.x = self.x - v.x
  self.y = self.y - v.y
proc `-=`*(self: var Vector3D, v: Vector3D) =
  self.x = self.x - v.x
  self.y = self.y - v.y
  self.z = self.z - v.z

proc `*`*(self: Vector2D, v: Vector2D): Vector2D =
  Vector2D(x: self.x * v.x, y: self.y * v.y)
proc `*`*(self: Vector3D, v: Vector3D): Vector3D =
  Vector3D(x: self.x * v.x, y: self.y * v.y, z: self.z * v.z)
proc `*`*(self: Vector2D, v: float32): Vector2D =
  Vector2D(x: self.x * v, y: self.y * v)
proc `*`*(self: Vector3D, v: float32): Vector3D =
  Vector3D(x: self.x * v, y: self.y * v, z: self.z * v)

proc `*=`*(self: var Vector2D, v: float32) =
  self.x = self.x * v
  self.y = self.y * v
proc `*=`*(self: var Vector3D, v: float32) =
  self.x = self.x * v
  self.y = self.y * v
  self.z = self.z * v
proc `*=`*(self: var Vector2D, v: Vector2D) =
  self.x = self.x * v.x
  self.y = self.y * v.y
proc `*=`*(self: var Vector3D, v: Vector3D) =
  self.x = self.x * v.x
  self.y = self.y * v.y
  self.z = self.z * v.z

proc `/`*(self: Vector2D, v: Vector2D): Vector2D =
  Vector2D(x: self.x / v.x, y: self.y / v.y)
proc `/`*(self: Vector3D, v: Vector3D): Vector3D =
  Vector3D(x: self.x / v.x, y: self.y / v.y, z: self.z / v.z)
proc `/`*(self: Vector2D, v: float32): Vector2D =
  Vector2D(x: self.x / v, y: self.y / v)
proc `/`*(self: Vector3D, v: float32): Vector3D =
  Vector3D(x: self.x / v, y: self.y / v, z: self.z / v)

proc `/=`*(self: var Vector2D, v: float32) =
  self.x = self.x / v
  self.y = self.y / v
proc `/=`*(self: var Vector3D, v: float32) =
  self.x = self.x / v
  self.y = self.y / v
  self.z = self.z / v
proc `/=`*(self: var Vector2D, v: Vector2D) =
  self.x = self.x / v.x
  self.y = self.y / v.y
proc `/=`*(self: var Vector3D, v: Vector3D) =
  self.x = self.x / v.x
  self.y = self.y / v.y
  self.z = self.z / v.z

proc magSq*(self: Vector2D): float32 =
  (self.x * self.x) + (self.y * self.y)
proc magSq*(self: Vector3D): float32 =
  (self.x * self.x) + (self.y * self.y) + (self.z * self.z)

proc mag*(self: Vector2D): float32 =
  sqrt(self.magSq())
proc mag*(self: Vector3D): float32 =
  sqrt(self.magSq())

proc dist*(self: Vector2D, v: Vector2D): float32 =
  mag(self - v)
proc dist*(self: Vector3D, v: Vector3D): float32 =
  mag(self - v)

proc normalize*(self: var Vector2D) =
  self /= self.mag()
proc normalize*(self: var Vector3D) =
  self /= self.mag()

proc perpendicular*(self: Vector2D): Vector2D =
  result.x = -self.y
  result.y = self.x

#[
  overlay
]#

proc getWindowInfo(name: string): WinInfo =
  let 
    p = startProcess("xwininfo", "", ["-name", name], options={poUsePath, poStdErrToStdOut})
    (lines, exitCode) = p.readLines()

  template parseI: int32 = parseInt(i.split()[^1]).int32

  if exitCode != 1:
    for i in lines:
      if "te upper-left X:" in i:
        result.upperX = parseI
      elif "te upper-left Y:" in i:
        result.upperY = parseI
      elif "Width:" in i:
        result.width = parseI
      elif "Height:" in i:
        result.height = parseI
  else:
    raise newException(IOError, "XWinInfo failed")

proc initOverlay*(name: string = "Overlay", target: string = "Fullscreen"): Overlay =
  var wInfo: WinInfo
  assert glfwInit()

  glfwWindowHint(GLFWFloating, GLFWTrue)
  glfwWindowHint(GLFWDecorated, GLFWFalse)
  glfwWindowHint(GLFWResizable, GLFWFalse)
  glfwWindowHint(GLFWTransparentFramebuffer, GLFWTrue)
  glfwWindowHint(GLFWSamples, 10)
  # GLFW Version 3.4 required 
  glfwWindowHint(GLFWMouseButtonPassthrough, GLFWTrue)

  result.videoMode = getVideoMode(glfwGetPrimaryMonitor())
  if target == "Fullscreen":
    result.width = result.videoMode.width - 1
    result.height = result.videoMode.height - 1
    result.midX = result.videoMode.width div 2
    result.midY = result.videoMode.height div 2
  else:
    wInfo = getWindowInfo(target)
    result.width = wInfo.width
    result.height = wInfo.height
    result.midX = result.width div 2
    result.midY = result.height div 2

  result.window = glfwCreateWindow(result.width.int32, result.height.int32, name, icon=false)
  result.window.makeContextCurrent()
  glfwSwapInterval(1)
  
  assert glInit()
  glutInit()
  glPushAttrib(GL_ALL_ATTRIB_BITS)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glOrtho(0, result.width.float64, 0, result.height.float64, -1, 1)
  glDisable(GL_DEPTH_TEST)
  glDisable(GL_TEXTURE_2D)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  if target != "Fullscreen":
    result.window.setWindowPos(wInfo.upperX, wInfo.upperY)

proc update*(self: Overlay) =
  self.window.swapBuffers()
  glfwPollEvents()
  glClear(GL_COLOR_BUFFER_BIT)

proc deinit*(self: Overlay) =
  self.window.destroyWindow()
  glfwTerminate()

proc close*(self: Overlay) = 
  self.window.setWindowShouldClose(true) 

proc loop*(self: Overlay): bool =
  self.update()
  not self.window.windowShouldClose()

#[
  2d drawings
]#

proc box*(x, y, width, height, lineWidth: float, color: array[0..2, float32]) =
  glLineWidth(lineWidth)
  glBegin(GL_LINE_LOOP)
  glColor3f(color[0], color[1], color[2])
  glVertex2f(x, y)
  glVertex2f(x + width, y)
  glVertex2f(x + width, y + height)
  glVertex2f(x, y + height)
  glEnd()

proc alphaBox*(x, y, width, height: float, color, outlineColor: array[0..2, float32], alpha: float) =
  box(x, y, width, height, 1.0, outlineColor)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glBegin(GL_POLYGON)
  glColor4f(color[0], color[1], color[2], alpha)
  glVertex2f(x, y)
  glVertex2f(x + width, y)
  glVertex2f(x + width, y + height)
  glVertex2f(x, y + height)
  glEnd()
  glDisable(GL_BLEND)

proc cornerBox*(x, y, width, height: float, color, outlineColor: array[0..2, float32], lineWidth: float = 1) =
  template drawCorner =
    glBegin(GL_LINES)
    # Lower Left
    glVertex2f(x, y); glVertex2f(x + lineW, y)
    glVertex2f(x, y); glVertex2f(x, y + lineH)

    # Lower Right
    glVertex2f(x + width, y); glVertex2f(x + width, y + lineH)
    glVertex2f(x + width, y); glVertex2f(x + width - lineW, y)

    # Upper Left
    glVertex2f(x, y + height); glVertex2f(x, y + height - lineH)
    glVertex2f(x, y + height); glVertex2f(x + lineW, y + height)

    # Upper Right
    glVertex2f(x + width, y + height); glVertex2f(x + width, y + height - lineH)
    glVertex2f(x + width, y + height); glVertex2f(x + width - lineW, y + height)
    glEnd()

  let
    lineW = width / 4
    lineH = height / 3

  glLineWidth(lineWidth + 2)
  glColor3f(outlineColor[0], outlineColor[1], outlineColor[2])
  drawCorner()
  glLineWidth(lineWidth)
  glColor3f(color[0], color[1], color[2])
  drawCorner()

proc line*(x1, y1, x2, y2, lineWidth: float, color: array[0..2, float32]) =
  glLineWidth(lineWidth)
  glBegin(GL_LINES)
  glColor3f(color[0], color[1], color[2])
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glEnd()

proc dashedLine*(x1, y1, x2, y2, lineWidth: float, color: array[0..2, float32], factor: int32 = 2, pattern: string = "11111110000", alpha: float32 = 0.5) =
  glPushAttrib(GL_ENABLE_BIT)
  glLineStipple(factor, fromBin[uint16](pattern))
  glLineWidth(lineWidth)
  glEnable(GL_LINE_STIPPLE)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  glBegin(GL_LINES)
  glColor4f(color[0], color[1], color[2], alpha)
  glVertex2f(x1, y1)
  glVertex2f(x2, y2)
  glEnd()
  glPopAttrib()

proc circle*(x, y, radius: float, color: array[0..2, float32], filled: bool = true) =
  if filled: glBegin(GL_POLYGON)
  else: glBegin(GL_LINE_LOOP)

  glColor3f(color[0], color[1], color[2])
  for i in 0..<360:
    glVertex2f(
      cos(degToRad(i.float32)) * radius + x,
      sin(degToRad(i.float32)) * radius + y
    )
  glEnd()

proc radCircle*(x, y, radius: float, value: int, color: array[0..2, float32]) =
  glBegin(GL_POLYGON)
  glColor3f(color[0], color[1], color[2])
  for i in 0..value:
    glVertex2f(
      cos(degToRad(i.float32)) * radius + x,
      sin(degToRad(i.float32)) * radius + y
    )
  glEnd()

proc valueBar*(x1, y1, x2, y2, width, maxValue, value: float, vertical: bool = true)  =
  if value > maxValue:
    raise newException(Exception, "ValueBar: Max Value > value")

  let
    x = value / maxValue
    barY = (y2 - y1) * x + y1
    barX = (x2 - x1) * x + x1
    color = [(2.0 * (1 - x)).float32, (2.0 * x).float32, 0.float32]

  line(x1, y1, x2, y2, width + 3.0, [0.float32, 0, 0])

  if vertical:
    line(x1, y1, x2, barY, width, color)
  else:
    line(x1, y1, barX, y2, width, color)

proc renderString*(x, y: float, text: string, color: array[0..2, float32], align: bool = false) =
  glColor3f(color[0], color[1], color[2])

  if align:
    glRasterPos2f(x - (glutBitmapLength(GLUT_BITMAP_HELVETICA_12, text).float / 2), y)
  else:
    glRasterPos2f(x, y)

  for c in text:
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, ord(c))

#[
  misc
]#

proc color*(color: string): array[0..2, float32] =
  try:
    let c = parseColor(color).extractRGB()
    [c.r.float32, c.g.float32, c.b.float32]
  except:
    [0.float32, 0, 0]

