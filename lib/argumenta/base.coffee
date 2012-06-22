Errors = require '../argumenta/errors'

# An extensible base class supporting custom errors.
# Example:
#
#   class Errors
#     @Another: class AnotherError extends Base.Error
#
#   class Another extends Base
#
#     Error: @Error = @Errors.Another
#
#     constructor: (@foo) ->
#       unless @foo is 'valid!'
#         throw new @Error "Invalid foo."
class Base

  # Prototype and static refs to the errors module
  Errors: @Errors = Errors

  # Prototype and static refs to the base error class
  Error: @Error = Errors.Base

module.exports = Base
