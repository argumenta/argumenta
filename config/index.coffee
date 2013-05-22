_        = require 'underscore'
coffee   = require 'coffee-script'

appMode = process.env.NODE_ENV or 'development'
configDir = process.env.CONFIG_DIR or './deploy'

# Default, app mode, deploy and environment configs
defaults   = require './defaults.json'
deployConf = (try require "#{configDir}/#{appMode}.json") or null
modeConf   = (try require "./modes/#{appMode}.json") or null
envConf    = require './env'

Config   = _.extend {}, defaults, modeConf, deployConf, envConf

module.exports = Config
