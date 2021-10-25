import render

var 
  csPid*, clientBase*: int
  overlay*: Overlay

const Offsets* = (
  dwLocalPlayer: 0x22b25f0,
  dwEntityList: 0x22e2a48,
  dwViewMatrix: 0x22b6a64,

  m_nForceBone: 0x2c54,
  m_vecOrigin: 0x170,
  m_bDormant: 0x125,
  m_angRotation: 0x164,
  m_iHealth: 0x138,
  m_iTeamNum: 0x12c,
  m_iName: 0x18c,
)

const BaseColors* = (
  white: color("white"),
  black: color("black"),
  cyan: color("cyan"),
  red: color("red"),
  orange: color("orange"),
)

type
  Entity* = object
    address*: ByteAddress
    dormant*: bool
    hPos3D*, pos3D*: Vector3D
    hPos2D*, pos2D*: Vector2D
    health*, team*: int32
    color*: array[0..2, float32]