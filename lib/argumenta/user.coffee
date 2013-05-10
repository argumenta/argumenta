BaseError = require '../argumenta/base_error'

#
# User models a user account.
#
class User

  ### Errors ###

  Error: @Error = class UserError extends BaseError
  ValidationError: @ValidationError = class ValidationError extends BaseError

  ### Constructor ###

  # Creates a user instance.
  #
  #     user = new User
  #       username:      'demosthenes'
  #       email:         'demos@athens.net'
  #       passwordHash:  '$2a$12$6nZyzVgeCmBK9JkZb9rNG.9s/d/i/g2Tbyf4vk318XQLQKi4GXXZ2'
  #       joinDate:      new Date()
  #       joinIp:        '127.0.0.1'
  #
  # @api public
  # @see Users#create()
  # @param [Object] params A hash of user params.
  # @param [String] params.username The user's login name.
  # @param [String] params.email    The user's email adress.
  # @param [String] params.passwordHash The user's password hash.
  constructor: (@username, @email, @passwordHash, @joinDate, @joinIp) ->
    if arguments.length == 1 and arguments[0].username
      params = arguments[0]
      @username      = params.username
      @email         = params.email
      @passwordHash  = params.passwordHash or params.password_hash
      @joinDate      = params.joinDate or params.join_date
      @joinIp        = params.joinIp or params.join_ip

  ### Instance Methods ###

  # Checks for equality with another user instance.
  #
  #     isEqual = user1.equals( user2 )
  #
  # @api public
  # @param [User] user The other user.
  # @return [Boolean] The equality result.
  equals: (user) ->
    return user instanceof User and
      user.username == @username and
      user.email == @email and
      user.passwordHash == @passwordHash

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
      @validateUsername() and @validatePasswordHash() and @validateEmail()
      @validationStatus = true
      @validationError = null
    catch err
      @validationStatus = false
      @validationError = err
    finally
      return @validationStatus

  #### Instance Field Validators ####

  # Each calls the static validator, passing parameters from the instance:
  #
  #     try
  #       isValid = user.validateUsername()
  #     catch validationErr
  #       message = validationErr.message
  #
  # @throws ValidationError
  # @return [Boolean] True only on success
  #
  validateUsername: () ->
    User.validateUsername @username

  validatePasswordHash: () ->
    User.validatePasswordHash @passwordHash

  validateEmail: () ->
    User.validateEmail @email

  ### Static Methods ###

  #### Static Validators ####

  # In addition to validated user instances, static validators are available.
  # Each throws an error on failure describing the problem, or returns true:
  #
  #     try
  #       isValid = User.validateUsername('demosthenes42')
  #     catch validateErr
  #       message = validateErr.message
  #
  # @throws ValidationError
  # @return [Boolean] True only on success
  #
  @validateUsername: (username) ->
    unless username?
      throw new @ValidationError "Username must exist"

    unless /\S+/.test username
      throw new @ValidationError "Username must not be blank"

    unless /^\S+$/.test username
      throw new @ValidationError "Username may not contain spaces"

    return true

  @validatePassword: (password) ->
    unless password?
      throw new @ValidationError "Password must exist"

    unless /\S+/.test password
      throw new @ValidationError "Password must not be blank"

    unless /.{6,}/.test password
      throw new @ValidationError "Password must be at least six characters"

    return true

  @validatePasswordHash: (passwordHash) ->
    unless passwordHash?
      throw new @ValidationError "Password hash must exist"

    unless /\S+/.test passwordHash
      throw new @ValidationError "Password hash must not be blank"

    return true

  @validateEmail: (email) ->
    unless email?
      throw new @ValidationError "Email must exist"

    unless /\S+/.test email
      throw new @ValidationError "Email must not be blank"

    unless /.+@..+/.test email
      throw new @ValidationError "Email must be valid"

    return true

module.exports = User
