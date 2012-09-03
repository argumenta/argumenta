bcrypt = require 'bcrypt'
Base   = require '../argumenta/base'

class Auth extends Base

  # Class Properties
  # ----------------

  # A custom error for this class.
  Error: @Error = @Errors.Auth

  # The bcrypt cost; log_2 of the number of rounds performed.
  @bcryptCost = parseInt(process.env.BCRYPT_COST, 10) or 10

  # Constructor
  # -----------

  # Construct a new `Auth` object for an `argumenta` instance:
  #
  #     auth = new Auth( argumenta )
  #
  # @param [Argumenta] argumenta Provides storage access.
  constructor: (@argumenta) ->

  # Instance Methods
  # ----------------

  # Verify login credentials `username` and `password` match a user account:
  #
  #     argumenta.auth.verifyLogin username, password, (err, result) ->
  #       if result and not err
  #           console.log 'verified!'
  #
  # @param [String]   username The login username.
  # @param [String]   password The login password.
  # @param [Function] callback(err, result) Called on success or error.
  # @param [AuthError|StorageError] err Any auth or storage error.
  # @param [Boolean]  result The verification result.
  verifyLogin: (username, password, callback) ->

    @argumenta.storage.getPasswordHash username, (err, hash) ->
      return callback err, null if err

      Auth.verifyPassword password, hash, (err, result) ->
        return callback err, null if err
        return callback null, result

  # Static Methods
  # --------------

  # Hash a `password` asynchronously with bcrypt:
  #
  #     password = 'secret'
  #     Auth.hashPassword password, (err, hash) ->
  #       if not err                 # success
  #         typeof hash is 'string'  # true, it's the bcrypt hash
  #
  # @see Auth.bcryptCost
  # @param [String]    password The password to hash.
  # @param [Function]  callback(err, hash) Called on completion or error.
  # @param [AuthError] err Wraps any bcrypt error; otherwise null.
  # @param [String]    hash Passed to callback on success.
  @hashPassword: (password, callback) ->

    cost = Auth.bcryptCost
    bcrypt.genSalt cost, (err, salt) ->
      return callback new @Error("Error generating salt.", err), null if err

      bcrypt.hash password, salt, (err, hash) ->
        return callback new @Error("Error generating hash.", err), null if err
        return callback null, hash

  # Verify a `password` by comparing with a bcrypt `hash`:
  #
  #     Auth.verifyPassword 'secret', hash, (err, result) ->
  #       if not err
  #         if result is true
  #           console.log 'verified!'
  #         else
  #           console.log 'password incorrect!'
  #
  # @param [String]     password The password to verify.
  # @param [String]     hash The original bcrypt hash.
  # @param [Function]   callback(err, res) Called on completion or error.
  # @param [AuthError]  err Wraps any bcrypt error; otherwise null.
  # @param [Boolean]    res The verification result.
  @verifyPassword: (password, hash, callback) ->

    bcrypt.compare password, hash, (err, res) ->
      return callback new @Error("Error comparing password with hash.", err), null if err
      return callback null, res

module.exports = Auth
