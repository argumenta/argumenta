_        = require 'underscore'
fs       = require 'fs'
nib      = require 'nib'
stylus   = require 'stylus'

class Helpers

  ### Objects ###

  # Serializes an object dictionary as data.
  @data = (dict) ->
    data = {}
    for key, val of dict
      if _.isObject(val) and typeof val.data is 'function'
        data[key] = val.data()
      else if _.isArray(val) and typeof val[0]?.data is 'function'
        data[key] = val.map (obj) -> obj.data()
      else
        data[key] = dict[key]
    return data

  ### Filesystem ###

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

  ### CSS ###

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
