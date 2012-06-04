
class Argumenta

  @Logger: Logger = require './argumenta/logger'
  @Storage: Storage = require './argumenta/storage'

  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = @options
    storage = @storage = new Storage storageOpts

module.exports = Argumenta
