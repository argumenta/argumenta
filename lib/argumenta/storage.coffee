Base       = require '../argumenta/base'
User       = require '../argumenta/user'

class Storage extends Base

  # Errors
  # ------

  # A custom error class for general storage errors.
  Error: @Error = @Errors.Storage

  # A storage error indicating a resource conflict,
  # ie, attempts to overwrite existing users or objects.
  ConflictError: @ConflictError = @Errors.StorageConflict

  # Construction
  # ------------

  # Constructs a new storage instance, backed by a particular type of store.
  constructor: (@options = {}) ->
    {storageType} = @options

    LocalStore = require './storage/local_store'

    switch storageType
#     when 'mongo'
#       @store = new MongoStore {storageUrl: options.storageUrl}
      when 'local'
        @store = new LocalStore()
      else
        throw new @Error "Construction error: Invalid storageType: #{storageType}"

  # Add a user to the store, given a valid `user`.
  addUser: (user, cb) ->
    unless user instanceof User
      return cb new @Error "User instance required to add user."

    unless user.validate()
      return cb user.validationError

    @store.addUser user, (err) ->
      return cb err if err
      return cb null

  # Delete *all* entities from the store.
  clearAll: (cb) ->
    @store.clearAll (err) ->
      return cb err

  # Get a user by `username`, omitting sensitive information.
  # See: `getPasswordHash()`
  getUserByName: (username, cb) ->
    @store.getUserByName username, (err, user) ->
      return cb new @Error("Failed getting user: " + username, err) if err
      return cb null, user

  # Get a user's password hash, given `username`.
  getPasswordHash: (username, cb) ->
    @store.getPasswordHash username, (err, password_hash) ->
      return cb new @Error("Failed getting user: "  + username, err) if err
      return cb null, password_hash

  # Get an array of all users, omitting sensitive information.
  getAllUsers: (cb) ->
    @store.getAllUsers (err, users) ->
      return cb new @Error "Failed getting all users from store." if err
      return cb null, users

module.exports = Storage
