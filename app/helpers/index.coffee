fs       = require 'fs'
nib      = require 'nib'
stylus   = require 'stylus'

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

  # This helper uses stylus middleware if possible.
  #
  #     helpers.watchCSS( app, cssDir )
  #
  # @param [Express] app
  # @param [Object] cssDir
  @watchCSS = (app, cssDir) ->
    cssWritable = Helpers.writableSync cssDir
    if cssWritable
      app.use stylus.middleware
        src: cssDir
        compile: (str, path) ->
          return stylus(str)
            .set('filename', path)
            .set('compress', false)
            .use(nib())

module.exports = Helpers
