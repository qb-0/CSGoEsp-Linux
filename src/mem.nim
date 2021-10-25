import 
  os, strutils, sequtils, 
  posix, strformat

proc process_vm_readv(pid: int, local_iov: ptr IOVec, liovcnt: culong, remote_iov: ptr IOVec, riovcnt: culong, flags: culong): cint {.importc, header: "<sys/uio.h>", discardable.}
proc process_vm_writev(pid: int, local_iov: ptr IOVec, liovcnt: culong, remote_iov: ptr IOVec, riovcnt: culong, flags: culong): cint {.importc, header: "<sys/uio.h>", discardable.}

proc getPid*(name: string): int =
  let all_files = toSeq(walkDir("/proc", relative = true))
  for pid in mapIt(filterIt(all_files, isDigit(it.path[0])), parseInt(it.path)):
      let proc_name = readFile(fmt"/proc/{pid}/cmdline").rsplit("/")[^1]
      if name in proc_name:
        return pid
  raise newException(IOError, fmt"Process not found ({name})")

proc getModuleBase*(pid: int, moduleName: string): int =
  for l in lines(fmt"/proc/{pid}/maps"):
    if moduleName in l:
      return parseHexInt(l.split("-")[0])
  raise newException(IOError, fmt"Module not found ({moduleName})")

proc readMem*(pid: int, address: ByteAddress, t: typedesc): t =
  var
    iosrc, iodst: IOVec
    size = cast[csize_t](sizeof(t))

  iodst.iov_base = result.addr
  iodst.iov_len = size
  iosrc.iov_base = cast[pointer](address)
  iosrc.iov_len = size
  discard process_vm_readv(pid, iodst.addr, 1, iosrc.addr, 1, 0)

proc readString*(pid: int, address: ByteAddress): string =
  let b = readMem(pid, address, array[0..100, char])
  result = $cast[cstring](b[0].unsafeAddr)

proc writeMem*(pid: int, address: ByteAddress, data: any): int {.discardable.} =
  var
    iosrc, iodst: IOVec
    size = cast[csize_t](sizeof(data))
    d = data

  iosrc.iov_base = d.addr
  iosrc.iov_len = size
  iodst.iov_base = cast[pointer](address)
  iodst.iov_len = size
  process_vm_writev(pid, iosrc.addr, 1, iodst.addr, 1, 0)