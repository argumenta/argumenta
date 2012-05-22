Storage = require './argumenta/storage'

class Argumenta

  constructor: (@options = {}) ->
    storageOpts = {storageType, storageUrl} = @options
    storage = @storage = new Storage storageOpts

module.exports = Argumenta
