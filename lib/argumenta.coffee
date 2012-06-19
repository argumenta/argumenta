Auth    = require './argumenta/auth'
Logger  = require './argumenta/logger'
Storage = require './argumenta/storage'

class Argumenta

  # Constructor
  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = options

    # Set log level
    Logger.LogLevel = options.logLevel

    # Auth and Storage instances
    @auth = new Auth this
    @storage = new Storage storageOpts

module.exports = Argumenta
