bcrypt = require 'bcrypt'
Base   = require '../argumenta/base'
Errors = require '../argumenta/errors'

class Auth extends Base

  # Class Properties
  # ----------------

  # A custom error for this class.
  Error: @Error = Errors.Auth

  # The bcrypt cost; log_2 of the number of rounds performed.
  @bcryptCost = 10

  # Constructor
  # -----------

  # Construct a new `Auth` object for an `argumenta` instance:
  #
  #     auth = new Auth( argumenta )
  #
  constructor: (@argumenta, options) ->

  # Prototype
  # ---------

  # Verify login credentials `username` and `password` match a user account:
  #
  #     argumenta.auth.verifyLogin username, password, (err, result) ->
  #       if result and not err
  #           console.log 'verified!'
  #
  verifyLogin: (username, password, callback) ->

    @argumenta.storage.getPasswordHash username, (err, hash) ->
      return callback err, null if err

      Auth.verifyPassword password, hash, (err, verifyResult) ->
        return callback err, null if err
        return callback null, verifyResult

  # Static Methods
  # --------------

  # Hash a `password` asynchronously with bcrypt:
  #
  #     password = 'secret'
  #     Auth.hashPassword password, (err, hash) ->
  #       if not err                 # success
  #         typeof hash is 'string'  # true, it's the bcrypt hash
  #
  # See `Auth.bcryptCost`.
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
  # - `password`           _String_    The password to verify.
  # - `hash`               _String_    The original bcrypt hash.
  # - `callback(err, res)` _Function_  Called on completion or error.
  # - `err`                _AuthError_ An AuthError wrapping any bcrypt error, or null.
  # - `res`                _Boolean_   The verification result.
  @verifyPassword: (password, hash, callback) ->

    bcrypt.compare password, hash, (err, res) ->
      return callback new @Error("Error comparing password with hash.", err), null if err
      return callback null, res

module.exports = Auth
