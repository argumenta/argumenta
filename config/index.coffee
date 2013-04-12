_        = require 'underscore'
coffee   = require 'coffee-script'

appMode = process.env.NODE_ENV or 'development'
configDir = process.env.CONFIG_DIR or './deploy'

# Default, app mode, deploy and environment configs
defaults   = require './defaults.coffee'
deployConf = (try require "#{configDir}/#{appMode}.coffee") or null
modeConf   = (try require "./modes/#{appMode}.coffee") or null
envConf    = require './env'

Config   = _.extend {}, defaults, modeConf, deployConf, envConf

module.exports = Config
