import render, globals

proc wts*(a: Overlay, matrix: array[0..15, float32], pos: Vec3, pos2d: ptr Vec2): bool =
  var 
    clip: Vec3
    ndc: Vec2

  # z = w
  clip.z = pos.x * matrix[12] + pos.y * matrix[13] + pos.z * matrix[14] + matrix[15]
  if clip.z < 0.2:
    return false

  clip.x = pos.x * matrix[0] + pos.y * matrix[1] + pos.z * matrix[2] + matrix[3]
  clip.y = pos.x * matrix[4] + pos.y * matrix[5] + pos.z * matrix[6] + matrix[7]

  ndc.x = clip.x / clip.z
  ndc.y = clip.y / clip.z

  pos2d.x = (a.width / 2 * ndc.x) + (ndc.x + a.width / 2)
  pos2d.y = (a.height / 2 * ndc.y) + (ndc.y + a.height / 2)
  result = true

proc renderBox*(self: Entity) =
  var
    head = self.hPos2D.y - self.pos2D.y
    width = head / 2
    center = width / -2
  
  cornerBox(
    self.pos2D.x + center, 
    self.pos2D.y, 
    width, 
    head + 5, 
    self.color,
    BaseColors.black,
    1
  )

proc renderHealth*(self: Entity) =
  var
    head = self.hPos2D.y - self.pos2D.y
    width = head / 2
    center = width / -2

  valueBar(
    self.pos2D.x + center - 5, self.pos2D.y,
    self.pos2D.x + center - 5, self.hPos2D.y + 5,
    2,
    100.float,
    self.health.float,
  )

proc renderSnapline*(self: Entity, midX: int) =
  dashedLine(
    midX.float, 0, 
    self.pos2D.x, self.pos2D.y, 1.0, 
    self.color,
  )

proc renderDistance*(self, local: Entity) =
  renderString(
    self.pos2D.x, self.pos2D.y - 15,
    $(self.pos3D.dist(local.pos3D) / 20).int32 & "m",
    BaseColors.white,
    true
  )