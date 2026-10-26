# silverpurge — SilverArch system cleanup
# Author: Silvercore (s1lverarch) <s1lv3rcore@proton.me>
# Website: https://s1lverarch.github.io/linuxdistro/
# License: GPL-3.0

import std/[os, osproc, strutils, strformat, sequtils, times]

const
  Version = "0.1.0"
  LogFile = "/var/log/silverpurge.log"
  catNames = ["orphans", "cache", "logs", "trash", "thumbnails"]

type Category = enum
  cOrphans, cCache, cLogs, cTrash, cThumbs

const
  cReset  = "\x1b[0m"
  cBold   = "\x1b[1m"
  cBlue   = "\x1b[38;2;0;191;255m"
  cGreen  = "\x1b[38;2;0;255;127m"
  cYellow = "\x1b[38;2;255;215;0m"
  cRed    = "\x1b[38;2;255;68;102m"

proc say(tag, color, msg: string) =
  echo " " & color & cBold & tag & cReset & " " & msg

proc info(m: string) = say("::", cBlue, m)
proc ok(m: string) = say("✓", cGreen, m)
proc warn(m: string) = say("!", cYellow, m)

proc die(m: string) =
  say("✘", cRed, m)
  quit(1)

proc isRoot(): bool =
  execCmdEx("id -u")[0].strip() == "0"

# Real user's home, even when run via sudo
proc realHome(): string =
  let su = getEnv("SUDO_USER")
  if su.len > 0 and su != "root":
    result = "/home" / su
  else:
    result = getHomeDir()

proc askLine(prompt: string): string =
  stdout.write(" " & cYellow & cBold & "»" & cReset & " " & prompt & " ")
  stdout.flushFile()
  try:
    result = stdin.readLine().strip()
  except EOFError:
    result = ""

proc confirm(q: string): bool =
  askLine(q).toLowerAscii() in ["y", "yes"]

proc logLine(msg: string) =
  let line = now().format("yyyy-MM-dd HH:mm:ss") & "  " & msg & "\n"
  try:
    let f = open(LogFile, fmAppend)
    f.write(line)
    f.close()
  except IOError, OSError:
    warn("cannot write " & LogFile & " (run with sudo)")

proc fileRoot(c: Category): string =
  case c
  of cTrash: result = realHome() / ".local/share/Trash/files"
  of cThumbs: result = realHome() / ".cache/thumbnails"
  else: result = ""

proc duSize(p: string): string =
  if not (dirExists(p) or fileExists(p)):
    return "0"
  let (o, _) = execCmdEx("du -sh " & quoteShell(p))
  result = o.split('\t')[0].strip()

type Scan = object
  items: seq[string]
  summary: string

proc scan(c: Category): Scan =
  case c
  of cOrphans:
    let (o, _) = execCmdEx("pacman -Qdtq")
    result.items = o.strip().splitLines().filterIt(it.len > 0)
    result.summary = $result.items.len & " package(s)"
  of cCache:
    result.summary = duSize("/var/cache/pacman/pkg") & " (keeps 2 versions)"
  of cLogs:
    let (o, _) = execCmdEx("journalctl --disk-usage")
    result.summary = o.strip()
  of cTrash, cThumbs:
    let root = fileRoot(c)
    if dirExists(root):
      for _, p in walkDir(root):
        result.items.add p
    result.summary = $result.items.len & " item(s), " & duSize(root)

# Move to backup dir when backupDir is set, otherwise delete permanently
proc dispose(p, backupDir: string) =
  if backupDir.len > 0:
    createDir(backupDir)
    let dest = backupDir / extractFilename(p)
    if dirExists(p):
      moveDir(p, dest)
    else:
      moveFile(p, dest)
  else:
    if dirExists(p):
      removeDir(p)
    else:
      removeFile(p)

proc clean(c: Category, stamp: string) =
  let name = catNames[ord(c)]
  if c in {cOrphans, cCache, cLogs} and not isRoot():
    die(name & " needs root: sudo silverpurge clean " & name)

  let s = scan(c)
  case c
  of cOrphans:
    if s.items.len == 0:
      ok("no orphan packages")
    else:
      info("orphans: " & s.items.join(" "))
      if confirm("remove " & $s.items.len & " orphan(s)? [y/N]"):
        let code = execShellCmd("pacman -Rns " & s.items.join(" "))
        if code == 0:
          ok("orphans removed")
          logLine("removed orphans: " & s.items.join(" "))
        else:
          warn("pacman exited with " & $code)

  of cCache:
    if confirm("clean package cache (keep 2 versions)? [y/N]"):
      if findExe("paccache").len == 0:
        warn("install pacman-contrib first")
      else:
        let code = execShellCmd("paccache -rk2")
        if code == 0:
          ok("package cache cleaned")
          logLine("cleaned package cache (kept 2 versions)")
        else:
          warn("paccache exited with " & $code)

  of cLogs:
    if confirm("vacuum journal older than 2 weeks? [y/N]"):
      let code = execShellCmd("journalctl --vacuum-time=2weeks")
      if code == 0:
        ok("journal vacuumed")
        logLine("vacuumed journal (older than 2 weeks)")
      else:
        warn("journalctl exited with " & $code)

  of cTrash, cThumbs:
    if s.items.len == 0:
      ok(name & " is empty")
    else:
      info(name & ": " & s.summary)
      let mode = askLine("backup or delete? [b/d]").toLowerAscii()
      if mode notin ["b", "d"]:
        warn("aborted")
      elif confirm("proceed? [y/N]"):
        let dest =
          if mode == "b": realHome() / ".local/share/silverpurge/backup" / stamp
          else: ""
        for p in s.items:
          dispose(p, dest)
        let action = if dest.len > 0: "backed up to " & dest else: "deleted permanently"
        ok(name & ": " & action)
        logLine(name & ": " & $s.items.len & " item(s) " & action)

proc parseCats(names: seq[string]): seq[Category] =
  if names.len == 0 or "all" in names:
    return @[cOrphans, cCache, cLogs, cTrash, cThumbs]
  for n in names:
    var idx = -1
    for i, nm in catNames:
      if nm == n.toLowerAscii():
        idx = i
    if idx < 0:
      die("unknown category: " & n)
    result.add Category(idx)

proc usage() =
  echo " silverpurge v" & Version & " — SilverArch system cleanup"
  echo ""
  echo " usage:"
  echo "   silverpurge [scan] [cat...]      dry-run: show what would be cleaned"
  echo "   sudo silverpurge clean [cat...]  clean (asks backup/delete for files)"
  echo "   silverpurge --version"
  echo ""
  echo " categories: orphans cache logs trash thumbnails all"

proc main() =
  let args = commandLineParams()
  let cmd = if args.len > 0: args[0] else: "scan"
  let rest = if args.len > 1: args[1..^1] else: @[]

  case cmd
  of "scan":
    echo ""
    for c in parseCats(rest):
      let s = scan(c)
      echo &"  {catNames[ord(c)]:<12} {s.summary}"
    echo ""
    info("dry-run only. to clean: sudo silverpurge clean <category|all>")
  of "clean":
    let stamp = now().format("yyyyMMdd-HHmmss")
    for c in parseCats(rest):
      clean(c, stamp)
  of "--version", "-v":
    echo "silverpurge v" & Version
  of "--help", "-h":
    usage()
  else:
    warn("unknown command: " & cmd)
    usage()
    quit(1)

main()
