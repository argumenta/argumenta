
# A static logging utility
class Logger

  # Default log level
  @DEFAULT_LEVEL = 'info'

  # Log level severity
  @SEVERITY =
    debug: 1
    info:  2
    warn:  3
    error: 4
    fatal: 5

  # Current log level
  @LogLevel = process.env.LOG_LEVEL or @DEFAULT_LEVEL

  # Set the current log level
  @setLevel: (level) ->
    @LogLevel = level if @SEVERITY[level]?

  # Static logging method
  @log = (level, message) ->
    if @SEVERITY[ level ] >= @SEVERITY[ @LogLevel ]
      console.log "[#{level}] " + message

module.exports = Logger
