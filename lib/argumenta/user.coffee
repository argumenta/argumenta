Base = require '../argumenta/base'

class User extends Base

  # Errors
  # ------

  Error: @Error = class UserError extends Base.Error
  ValidationError: @ValidationError = class ValidationError extends Base.Error

  # Static validator methods
  # ------------------------

  # In addition to validated user instances, static validators are available.
  # Each throws an error on failure describing the problem, or returns true:
  #
  #     try
  #       isValid = User.validateUsername('demosthenes42')
  #     catch validateErr
  #       message = validateErr.message
  @validateUsername: (username) ->
    unless /\S+/.test username
      throw new @ValidationError "Username must not be blank"

    unless /^\S+$/.test username
      throw new @ValidationError "Username may not contain spaces"

    return true

  @validatePassword: (password) ->
    unless /\S+/.test password
      throw new @ValidationError "Password must not be blank"

    unless /.{0,6}/.test password
      throw new @ValidationError "Password must be at least six characters"

    return true

  @validateEmail: (email) ->
    unless /\S+/.test email
      throw new @ValidationError "Email must not be blank"

    unless /.+@..+/.test email
      throw new @ValidationError "Email must be valid"

    return true

  # Construction
  # ------------

  # Creates a new user with the given attributes (username, password, and email):
  #
  #     user = new User
  #       username: 'demosthenes'
  #       password: 'secret'
  #       email:    'demos@athens.net'
  constructor: (params, opts={}) ->
    @username = params.username
    @email    = params.email
    @password = params.password

  # Validation
  # ----------

  # Performs instance validation, returns true on success:
  #
  #     isValid = user.validate()
  #
  # Also sets properties `validationStatus` and `validationError`:
  #
  #     user.validationStatus # True on success, otherwise false.
  #     user.validationError  # Null on success, otherwise the last error object.
  validate: () ->
    try
      @validateUsername() and @validatePassword() and @validateEmail()
      @validationStatus = true
      @validationError = null
    catch err
      @validationStatus = false
      @validationError = err
    finally
      return @validationStatus

  # Instance validator methods
  # --------------------------

  # Each calls the static validator, passing parameters from the instance:
  #
  #     try
  #       isValid = user.validateUsername()
  #     catch validationErr
  #       message = validationErr.message
  validateUsername: () ->
    User.validateUsername @username

  validatePassword: () ->
    User.validatePassword @password

  validateEmail: () ->
    User.validateEmail @email

module.exports = User
