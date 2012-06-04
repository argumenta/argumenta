_        = require 'underscore'

# Default, app mode, and environment configs
defaults = require './defaults'
modeConf = require './mode'
envConf  = require './env'

Config   = _.extend {}, defaults, modeConf, envConf

module.exports = Config
