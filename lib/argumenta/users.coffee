Base = require '../argumenta/base'
Auth = require '../argumenta/auth'
User = require '../argumenta/user'

#
# Users models user accounts.
# It integrates the Storage, Auth, and User modules.
#
class Users extends Base

  ### Errors ###

  Error: @Error = @Errors.Users
  ValidationError: @ValidationError = @Errors.Validation
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits a Users instance.
  #
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage] storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Creates a user account.
  #
  # Example:
  #
  #     users.create username, password, email, (err, user) ->
  #       console.log "created account for #{user.username}!" unless err
  #
  # @param [String] username The user's username.
  # @param [String] password The user's password.
  # @param [String] email The user's email.
  # @param [Function] callback(err, user) Called on error or success.
  # @param [Error] err Any error.
  # @param [User] user The new user.
  create: (username, password, email, callback) ->

    try User.validatePassword password
    catch err
      return callback err, null

    Auth.hashPassword password, (err, hash) =>
      return callback err, null if err

      user = new User { username, password_hash: hash, email }

      @storage.addUser user, (err) =>
        return callback err, null if err
        return callback null, user

module.exports = Users
