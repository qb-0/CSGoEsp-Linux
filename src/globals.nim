import render

var 
  acPid*, acBase*: int
  overlay*: Overlay

type Entity* = object
  address*: ByteAddress
  headPos3D*, feetPos3D*: Vector3D
  headPos2D*, feetPos2D*: Vector2D
  health*, team*: int32
  state*: int8
  color*: array[0..2, float32]
  name*: string

const Offsets* = (
  # Modulebase +
  localPlayer: 0x12E328,
  entList: 0x12E330,
  viewMatrix: 0x13D3DC,

  # Playerbase +
  headPos: 0x8,
  feetPos: 0x38,
  health: 0x110,
  name: 0x23D,
  team: 0x344,
  state: 0x86,
)

const BaseColors* = (
  white: color("white"),
  black: color("black"),
  cyan: color("cyan"),
  red: color("red")
)