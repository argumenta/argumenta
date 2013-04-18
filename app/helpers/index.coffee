fs = require 'fs'

class Helpers

  @canWrite = (isOwner, inGroup, mode) ->
    return (
      isOwner and (mode & 0o0200) or
      inGroup and (mode & 0o0020) or
                  (mode & 0o0002)
    )

  @canWriteBy = (proc, stat) ->
    return Helpers.canWrite(
      proc.getuid() == stat.uid,
      proc.getgid() == stat.gid,
      stat.mode
    )

  @writableSync = (path) ->
    return Helpers.canWriteBy process, fs.statSync(path)

module.exports = Helpers
