Base       = require '../argumenta/base'
User       = require '../argumenta/user'

class Storage extends Base

  # Errors
  # ------

  # Storage.Error: A custom error class for general storage errors.
  Error: @Error = class StorageError extends Base.Error

  # Storage.ConflictError: Indicates storage errors due to
  # resource conflicts; ie, attempts to overwrite existing resources.
  ConflictError: @ConflictError = class ConflictError extends StorageError

  # Construction
  # ------------

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

  getUserByName: (username, cb) ->
    @store.getUserByName username, (err, user) ->
      return cb new @Error("Failed getting user: " + username, err) if err
      return cb null, user

  # Get a password hash by username.
  getPasswordHash: (username, cb) ->
    @store.getPasswordHash username, (err, password_hash) ->
      return cb new @Error("Failed getting user: "  + username, err) if err
      return cb null, password_hash

  getAllUsers: (cb) ->
    @store.getAllUsers (err, users) ->
      return cb new @Error "Failed getting all users from store." if err
      return cb null, users

module.exports = Storage
