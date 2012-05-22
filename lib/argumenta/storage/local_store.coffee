
class LocalStore

  constructor: () ->
    # Init users hash
    @users = {}

  # Gets the public properties of a user by name.
  getUserByName: (name, cb) ->
    u = @users[name]
    user_safe = {name: u.name}
    cb null, user_safe

  # Gets the public properties of all users.
  getAllUsers: (cb) ->
    users_safe = []

    for name, u of @users
      u_safe = {name: u.name}
      users_safe.push u_safe

    # Success
    cb null, users_safe

module.exports = LocalStore
