import posix
import render, mem, input, globals, esp

template readMem(address: ByteAddress, t: untyped): untyped = readMem(csPid, address, t)

proc initEntity(address: ByteAddress, e: ptr Entity, vm: array[0..15, float32]): bool {.discardable.} =
  e.address = address
  e.dormant = readMem(address + Offsets.m_bDormant, bool)
  if e.dormant: 
    return
  e.health = readMem(address + Offsets.m_iHealth, int32)
  if e.health <= 0:
    return
  e.pos3D = readMem(address + Offsets.m_vecOrigin, Vec3)
  if not wts(overlay, vm, e.pos3D, e.pos2D.addr): 
    return
  let dwBoneMatrix = readMem(address + Offsets.m_nForceBone + 0x2C, int)
  e.hPos3D.x = readMem(dwBoneMatrix + 0x30 * 8 + 0x0C, float32)
  e.hPos3D.y = readMem(dwBoneMatrix + 0x30 * 8 + 0x1C, float32)
  e.hPos3D.z = readMem(dwBoneMatrix + 0x30 * 8 + 0x2C, float32)
  if not wts(overlay, vm, e.hPos3D, e.hPos2D.addr): 
    return
  e.team = readMem(address + Offsets.m_iTeamNum, int32)
  e.color = if e.team == 2: BaseColors.orange else: BaseColors.cyan
  result = true

proc main =
  if getuid() != 0:
    quit("Root required!")

  csPid = getPid("csgo_linux64")
  clientBase = getModuleBase(csPid, "client_client.so")
  overlay = initOverlay(target="Counter-Strike: Global Offensive - OpenGL")
  
  while overlay.loop():
    if keyPressed(XK_End):
      overlay.close()

    let localPlayerAddr = readMem(clientBase + Offsets.dwLocalPlayer, ByteAddress)
    if localPlayerAddr > 0:
      let
        vm = readMem(clientBase + Offsets.dwViewMatrix, array[0..15, float32])
        entBuffer = readMem(clientBase + Offsets.dwEntityList + 32, array[256, ByteAddress])

      var localEnt: Entity
      initEntity(localPlayerAddr, localEnt.addr, vm)

      for i in 1..63:
        let entAddr = ent_buffer[i * 4]
        if entAddr != 0 and entAddr != localPlayerAddr:
          var ent: Entity
          if initEntity(entAddr, ent.addr, vm):
            ent.renderBox()
            ent.renderHealth()
            ent.renderSnapline(overlay.midX)
            ent.renderDistance(localEnt)

  overlay.deinit()

when isMainModule:
  main()