Argumenta = require './lib/argumenta'
config    = require './config'

# Argumenta Instance
argumenta = new Argumenta
  storageType: config.storageType
  storageUrl:  config.storageUrl

module.exports = argumenta
