import posix, x11/keysym
import render, mem, input, esp, globals

template readMem(address: ByteAddress, t: untyped): untyped = readMem(acPid, address, t)

proc createEntity(a: ByteAddress, vm: array[0..15, float32]): Entity =
  var p = readMem(a, PlayerObject)
  result.address = a
  result.headPos3D = p.headPos
  result.headPos3D.z += 0.6
  result.feetPos3D = p.feetPos
  result.health = p.health
  result.team = p.team
  result.color = if p.team == 1: Basecolors.cyan else: Basecolors.red
  result.name = $cast[cstring](p.name[0].unsafeAddr)

  try:
    result.headPos2D = wts(overlay, vm, p.headPos)
    result.feetPos2D = wts(overlay, vm, p.feetPos)
  except:
    result.health = -1

proc main =
  if getuid() != 0:
    quit("Root required!")

  acPid = getPid("assaultcube")
  acBase = getModuleBase(acPid, "linux_64_client")
  overlay = initOverlay(target="AssaultCube")
  
  let entList = readMem(acBase + Offsets.entList, int)

  while overlay.loop():
    if keyPressed(XK_End):
      overlay.close()

    let viewMatrix = readMem(acBase + Offsets.viewMatrix, array[0..15, float32])
    for e in 0..31:
      let ent = createEntity(readMem(entList + e * 8, ByteAddress), viewMatrix)

      if ent.health > 0 and ent.health < 101:
        ent.renderBox()
        ent.renderHealth()
        ent.renderSnapline(overlay.midX)
        ent.renderName()

  overlay.deinit()

when isMainModule:
  main()