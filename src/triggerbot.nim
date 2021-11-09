import globals, input

proc checkTrigger*(self: Entity, e: Entity) =
  if self.team != e.team and self.crossId == e.id:
    clickMouse()