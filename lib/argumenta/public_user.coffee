User = require '../argumenta/user'

#
# PublicUser models a user account's public properties.  
# It omits sensitive fields, such as password_hash and email.
#
class PublicUser extends User

  ### Errors ###

  Error: @Error = @Errors.PublicUser
  ValidationError: @ValidationError = @Errors.Validation

  ### Constructor ###

  # Creates a user instance.
  #
  #     username = 'demosthenes'
  #     pubUser = new PublicUser( username )
  #
  # @api public
  # @see User
  # @param [String] username The user's login name.
  constructor: (@username) ->
    if arguments[0].username?
      @username = arguments[0].username

  ### Instance Methods ###

  # Checks for equality with another user instance.
  #
  #     isEqual = user1.equals( user2 )
  #
  # @api public
  # @param [User] user The other user.
  # @return [Boolean] The equality result.
  equals: (user) ->
    return user instanceof PublicUser and
      user.username == @username

  #### Validation ####

  # Validates a user instance.
  #
  #     isValid = user.validate()
  #
  # Also sets properties `validationStatus` and `validationError`:
  #
  #     user.validationStatus # True on success, otherwise false.
  #     user.validationError  # Null on success, otherwise the last error object.
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      @validateUsername()
      @validationStatus = true
      @validationError = null
    catch err
      @validationStatus = false
      @validationError = err
    finally
      return @validationStatus

module.exports = PublicUser
