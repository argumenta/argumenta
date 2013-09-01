Auth      = require './argumenta/auth'
Logger    = require './argumenta/logger'
Storage   = require './argumenta/storage'
Arguments = require './argumenta/arguments'
Search    = require './argumenta/search'
Tags      = require './argumenta/tags'
Users     = require './argumenta/users'

class Argumenta

  # Constructor
  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = options

    # Set log level
    Logger.setLevel options.logLevel

    # Auth, Storage, and Collections instances
    @auth      = new Auth this
    @storage   = new Storage storageOpts
    @arguments = new Arguments this, @storage
    @search    = new Search this, @storage
    @tags      = new Tags this, @storage
    @users     = new Users this, @storage

module.exports = Argumenta
