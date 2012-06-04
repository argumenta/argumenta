config    = require '../config'
Argumenta = require '../lib/argumenta'

# Log level
Argumenta.Logger.LogLevel = config.logLevel

# Argumenta Instance
argumenta = new Argumenta
  storageType: config.storageType
  storageUrl:  config.storageUrl

module.exports = argumenta
