Auth         = require './argumenta/auth'
Logger       = require './argumenta/logger'
Storage      = require './argumenta/storage'
Arguments    = require './argumenta/collections/arguments'
Comments     = require './argumenta/collections/comments'
Discussions  = require './argumenta/collections/discussions'
Propositions = require './argumenta/collections/propositions'
Publications = require './argumenta/collections/publications'
Tags         = require './argumenta/collections/tags'
Users        = require './argumenta/collections/users'
Search       = require './argumenta/search'

class Argumenta

  # Constructor
  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = options

    # Set log level
    Logger.setLevel options.logLevel

    # Auth, Storage, and Collections instances
    @auth         = new Auth this
    @storage      = new Storage storageOpts
    @arguments    = new Arguments this, @storage
    @comments     = new Comments this, @storage
    @discussions  = new Discussions this, @storage
    @propositions = new Propositions this, @storage
    @publications = new Publications this, @storage
    @search       = new Search this, @storage
    @tags         = new Tags this, @storage
    @users        = new Users this, @storage

module.exports = Argumenta
