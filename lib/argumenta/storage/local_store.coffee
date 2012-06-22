Base    = require '../../argumenta/base'

class LocalStore extends Base

  # Prototype and static refs to custom error class.
  Error: @Error = @Errors.LocalStore

  constructor: () ->
    # Init users hash
    @users = {}

  # Store a User in memory.
  addUser: (user, cb) ->
    # Check for existing user
    if @users[user.username]
      return cb new @Errors.StorageConflict 'User already exists.'

    # Store the user
    @users[user.username] = user

    # Success
    return cb null

  # Delete *all* entities from the store.
  clearAll: (cb) ->
    delete @users[name] for name in Object.keys @users
    @users = {}

    return cb null

  # Gets the *public* properties of a user by name.
  getUserByName: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    publicUser = {username: u.username}

    return cb null, publicUser

  getPasswordHash: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    return cb null, u.password_hash

  # Gets the *public* properties of all users.
  getAllUsers: (cb) ->

    publicUsers = []

    for name, u of @users
      publicUser = {username: u.username}
      publicUsers.push publicUser

    # Success
    return cb null, publicUsers

module.exports = LocalStore
