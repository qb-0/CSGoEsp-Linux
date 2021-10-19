import x11/keysym
import render, mem, input, esp, globals

template readMem(address: ByteAddress, t: untyped): untyped = readMem(acPid, address, t)
template readString(address: ByteAddress): string = readString(acPid, address)

proc createEntity(a: ByteAddress, vm: array[0..15, float32]): Entity =
  result.address = a
  result.headPos3D = readMem(a + Offsets.headPos, Vector3D)
  result.headPos3D.z += 0.6
  result.feetPos3D = readMem(a + Offsets.feetPos, Vector3D)
  result.health = readMem(a + Offsets.health, int32)
  result.team = readMem(a + Offsets.team, int32)
  result.state = readMem(a + Offsets.state, int8)
  result.color = if result.team == 1: Basecolors.cyan else: Basecolors.red
  result.name = readString(a + Offsets.name)

  try:
    result.headPos2D = wts(overlay, vm, result.headPos3D)
    result.feetPos2D = wts(overlay, vm, result.feetPos3D)
  except:
    result.health = -1

proc main =
  acPid = getPid("assaultcube")
  acBase = getModuleBase(acPid, "linux_64_client")
  overlay = initOverlay(target="AssaultCube")
  
  let entList = readMem(acBase + Offsets.entList, int)

  while overlay.loop():
    if keyPressed(XK_End):
      overlay.close()

    let viewMatrix = readMem(acBase + Offsets.viewMatrix, array[0..15, float32])
    for e in 0..32 - 1:
      let ent = createEntity(readMem(entList + e * 8, ByteAddress), viewMatrix)

      if ent.health > 0 and ent.health < 101:
        ent.renderBox()
        ent.renderHealth()
        ent.renderSnapline(overlay.midX)
        ent.renderName()

  overlay.deinit()

when isMainModule:
  main()