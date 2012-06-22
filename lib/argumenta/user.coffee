Base = require '../argumenta/base'
Auth = require '../argumenta/auth'

class User extends Base

  # Errors
  # ------

  Error: @Error = @Errors.User
  ValidationError: @ValidationError = @Errors.Validation

  # Static constructor
  # ------------------

  # Create a new user instance asynchronously from username, password, & email.
  # The password plaintext is hashed with bcrypt, & discarded.
  # The result is stored on the instance as `user.password_hash`:
  #
  #     params =
  #       username: 'demosthenes'
  #       password: 'secret'
  #       email:    'demos@athens.net'
  #
  #     User.new params, (err, user) ->
  #       if err is null
  #         user.password is null           # true; it's been discarded
  #         user.password_hash isnt null    # true; it's a string with the hash
  #
  @new: (params, callback) ->

    # Only proceed to hashing if password is valid.
    try
      User.validatePassword params.password
    catch err
      return callback err, null

    # Hash the password asynchronously.
    Auth.hashPassword params.password, (err, hash) ->
      return callback err, null if err

      # Discard the plaintext; keep the hash.
      delete params.password
      params.password_hash = hash

      # Create a new instance.
      user = new User params

      # Pass the instance to the callback.
      return callback null, user

  # Constructor
  # -----------

  # Create a user instance with given attributes (username, email, & password_hash):
  #
  #     user = new User
  #       username:      'demosthenes'
  #       email:         'demos@athens.net'
  #       password_hash: '$2a$12$6nZyzVgeCmBK9JkZb9rNG.9s/d/i/g2Tbyf4vk318XQLQKi4GXXZ2'
  #
  # See also: User.new()
  constructor: (params) ->
    @username      = params.username
    @email         = params.email
    @password_hash = params.password_hash

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
  #
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

  # Instance validators
  # -------------------

  # Each calls the static validator, passing parameters from the instance:
  #
  #     try
  #       isValid = user.validateUsername()
  #     catch validationErr
  #       message = validationErr.message
  #
  validateUsername: () ->
    User.validateUsername @username

  validatePasswordHash: () ->
    User.validatePasswordHash @passwordHash

  validateEmail: () ->
    User.validateEmail @email


  # Static validators
  # -----------------

  # In addition to validated user instances, static validators are available.
  # Each throws an error on failure describing the problem, or returns true:
  #
  #     try
  #       isValid = User.validateUsername('demosthenes42')
  #     catch validateErr
  #       message = validateErr.message
  #
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

  @validatePasswordHash: (password_hash) ->
    unless /\S+/.test password_hash
      throw new @ValidationError "Password hash must not be blank"

    return true

  @validateEmail: (email) ->
    unless /\S+/.test email
      throw new @ValidationError "Email must not be blank"

    unless /.+@..+/.test email
      throw new @ValidationError "Email must be valid"

    return true

module.exports = User
