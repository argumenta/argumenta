config    = require '../config'
Argumenta = require '../lib/argumenta'

# Argumenta Instance
argumenta = new Argumenta
  logLevel:    config.logLevel
  storageType: config.storageType
  storageUrl:  config.storageUrl
  storageUrl:  config[ config.storageType + 'Url' ]

module.exports = argumenta
