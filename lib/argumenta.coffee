Auth    = require './argumenta/auth'
Logger  = require './argumenta/logger'
Storage = require './argumenta/storage'
Users   = require './argumenta/users'

class Argumenta

  # Constructor
  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = options

    # Set log level
    Logger.LogLevel = options.logLevel

    # Auth, Storage and Users instances
    @auth = new Auth this
    @storage = new Storage storageOpts
    @users = new Users this, @storage

module.exports = Argumenta
