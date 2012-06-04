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

# An extensible base class supporting custom errors.
# Example:
#
#   class Another extends Base
#
#     Error: @Error = class AnotherError extends Base.Error
#
#     constructor: (@foo) ->
#       unless @foo is 'valid!'
#         throw new @Error "Invalid foo."
class Base

  # Prototype and static refs to the base error class
  Error: @Error = BaseError

module.exports = Base
