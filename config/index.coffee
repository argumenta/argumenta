_        = require 'underscore'

appMode = process.env.NODE_ENV or 'development'
configDir = process.env.CONFIG_DIR or './deploy'

# Default, app mode, deploy and environment configs
defaults   = require './defaults'
deployConf = (try require "#{configDir}/#{appMode}") or null
modeConf   = (try require "./modes/#{appMode}") or null
envConf    = require './env'

Config   = _.extend {}, defaults, modeConf, deployConf, envConf

module.exports = Config
