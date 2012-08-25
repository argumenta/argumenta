Base        = require '../argumenta/base'
User        = require '../argumenta/user'
Proposition = require '../argumenta/objects/proposition'

# Storage persists users and objects to a backend store.

class Storage extends Base

  # Construction
  # ------------

  # Constructs a new Storage instance, backed by a particular type of store.
  #
  # Create a memory-backed storage instance:
  #
  #     storage = new Storage
  #       storageType: 'local'
  #
  # Create a mongo-backed storage instance:
  #
  #     storage = new Storage
  #       storageType: 'mongo',
  #       storageUrl: 'mongodb://localhost:27017'
  #
  # @param [Object] opts The storage backing options.
  # @param [String] opts.storageType The backing type: 'local' or 'mongo'.
  # @param [String] opts.storageUrl  The backing url, if needed.
  constructor: (opts={}) ->
    {storageType} = opts

    LocalStore = require './storage/local_store'

    switch storageType
      when 'local'
        @store = new LocalStore()
      else
        throw new @Error "Construction error: Invalid storageType: #{storageType}"

  # Errors
  # ------

  # A custom error class for general storage errors.
  Error: @Error = @Errors.Storage

  # A storage error indicating a resource conflict,
  # ie, attempts to overwrite existing users or objects.
  ConflictError: @ConflictError = @Errors.StorageConflict

  # Instance Methods
  # ----------------

  # Add a user to the store.
  #
  # @param [User] user A valid user with a unique username.
  # @param [Function] cb(err) Called on completion or error.
  # @param [StorageError|ValidationError|StorageConflictError] err Any error.
  addUser: (user, cb) ->
    unless user instanceof User
      return cb new @Error "User instance required to add user."

    unless user.validate()
      return cb user.validationError

    @store.addUser user, (err) ->
      return cb err if err
      return cb null

  # Delete *all* entities from the store.
  #
  # @param [Function]     cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  clearAll: (cb) ->
    @store.clearAll (err) ->
      return cb err

  # Get a user by username, omitting sensitive fields.
  #
  # @see getPasswordHash()
  # @param [String]       username Of the user to retrieve.
  # @param [Function]     cb(err, user) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Object]       user The retrieved user's public fields.
  getUser: (username, cb) ->
    @store.getUser username, (err, user) ->
      return cb new @Error("Failed getting user: " + username, err) if err
      return cb null, user

  # Get a user's password hash.
  #
  # @param [String]       username Of the user whose hash to retrieve.
  # @param [Function]     cb(err, hash) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [String]       hash The retrieved password hash.
  getPasswordHash: (username, cb) ->
    @store.getPasswordHash username, (err, hash) ->
      return cb new @Error("Failed getting user: "  + username, err) if err
      return cb null, hash

  # Get an array of all users, omitting sensitive fields.
  #
  # @param [Function]      cb(err, users) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Object>] users An object array of users' public fields.
  getAllUsers: (cb) ->
    @store.getAllUsers (err, users) ->
      return cb new @Error "Failed getting all users from store." if err
      return cb null, users

  # Add an array of propositions to the store.
  #
  # @param [Array<Propositions>] propositions The propositions array.
  # @param [Function]     cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  addPropositions: (propositions, cb) ->
    for p in propositions
      unless p instanceof Proposition
        return cb new @Error("Won't add non-proposition: " + p)
      unless p.validate()
        return cb new @Error("Won't add invalid proposition: " + p)

    @store.addPropositions propositions, (err) ->
      return cb new @Error "Failed adding propositions to the store." if err
      return cb null

  # Get propositions from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the propositions to retrieve.
  # @param [Function]      cb(err, propositions) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Proposition>] propositions The retrieved propositions.
  getPropositions: (hashes, cb) ->
    @store.getPropositions hashes, (err, propositions) ->
      return cb new @Error "Failed getting propositions from the store." if err
      return cb null, propositions

module.exports = Storage
