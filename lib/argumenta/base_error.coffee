Logger = require '../argumenta/logger'

# An error class with auto-logging and an errors stack.
# CoffeeScript enables classname awareness for child classes.
class BaseError extends Error

  # Creates an error, logs the classname and message,
  # and stores a stack of errors (including the new one).
  constructor: (@message, prevErr) ->
    Logger.log 'error', @constructor.name + ': ' + message

    @name = @constructor.name
    @errStack = []
    @errStack.push e for e in (prevErr.errStack or [prevErr]) if prevErr
    @errStack.push @

module.exports = BaseError
