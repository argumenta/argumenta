# Config.Mode: Config settings for the current app mode
appMode = process.env.NODE_ENV or 'development'
Mode = (try require './modes/' + appMode) or null

module.exports = Mode
