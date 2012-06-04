# Argumenta instance, User and Storage classes
argumenta = require '../argumenta'
User      = require '../../lib/argumenta/user'
Storage   = require '../../lib/argumenta/storage'

# Users index
exports.index = (req, res) ->
  argumenta.storage.getAllUsers (err, users) ->
    return res.reply 'index', 'Error loading users.' if err
    return res.reply 'users/index', title: 'Users', users: users

# Create a user via POST
exports.create = (req, res) ->
  user = new User req.body
  argumenta.storage.addUser user, (err) ->
    if not err
      switch req.param 'format'
        when 'json'
          return res.reply null,
            headers: 'Location': "/users/#{user.username}"
            message: "Created user."
            status: 201
        else
          req.flash 'message', "Welcome aboard, #{user.username}!"
          return res.redirect "users/#{user.username}"
    else
      if err instanceof User.ValidationError
        return res.reply 'index',
          error: "Error creating user: " + user.validationError.message,
          status: 400
      else if err instanceof Storage.ConflictError
        return res.reply 'index',
          error: "User already exists.",
          status: 409
      else
        return res.reply 'index',
          error: "Error storing user.",
          status: 500

# Show a user as html or json
exports.show = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Error getting user: Missing name."

  argumenta.storage.getUserByName name, (err, user) ->
    return res.reply 'index', error: "User '#{name}' not found.", status: 404 if err
    return res.reply 'users/user', user: user
