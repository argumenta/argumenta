
# A static logging utility
class Logger

  # Default and available log levels
  @LogLevel = 'info'
  @LogLevels = ['debug', 'info', 'warn', 'error', 'fatal']

  # Static logging method
  @log = (level, message) ->
    if @LogLevels.indexOf( level ) >= @LogLevels.indexOf( @LogLevel )
      console.log "[#{level}] " + message

module.exports = Logger
