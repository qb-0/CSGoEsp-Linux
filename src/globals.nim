import render

var 
  acPid*, acBase*: int
  overlay*: Overlay

const Offsets* = (
  # Modulebase +
  localPlayer: 0x12E328,
  entList: 0x12E330,
  viewMatrix: 0x13D3DC,
)

const BaseColors* = (
  white: color("white"),
  black: color("black"),
  cyan: color("cyan"),
  red: color("red")
)

type
  PlayerObject* {.bycopy.} = object
    pad_0000: array[8, char]   ## 0x0000
    headPos*: Vector3D         ## 0x0008
    pad_0014: array[36, char]  ## 0x0014
    feetPos*: Vector3D         ## 0x0038
    pad_0044: array[204, char] ## 0x0044
    health*: int32             ## 0x0110
    pad_0114: array[297, char] ## 0x0114
    name*: array[30, char]     ## 0x023D
    pad_025B: array[233, char] ## 0x025B
    team*: int32               ## 0x0344

  Entity* = object
    address*: ByteAddress
    headPos3D*, feetPos3D*: Vector3D
    headPos2D*, feetPos2D*: Vector2D
    health*, team*: int32
    color*: array[0..2, float32]
    name*: string