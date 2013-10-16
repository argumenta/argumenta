# Argumenta instance, User, Storage and Errors classes
argumenta = require '../app/argumenta'
Storage   = require '../lib/argumenta/storage'
Errors    = require '../lib/argumenta/errors'

# Users index
exports.index = (req, res) ->
  argumenta.storage.getAllUsers (err, users) ->
    return res.reply 'index', 'Error loading users.' if err
    return res.reply 'users/index', title: 'Users', users: users

# Create a user via POST
exports.create = (req, res) ->
  options = {
    username:  req.body.username
    password:  req.body.password
    email:     req.body.email
    join_date: new Date()
    join_ip:   req.ip
  }

  argumenta.users.create options, (err, user) ->
    if err
      return res.failed '/join', err.message,
        status: Errors.statusFor err
    else
      req.session.username = user.username
      return res.created "/#{user.username}",
        "Welcome aboard, #{user.username}!",
        user: user

# Show a user as html or json
exports.show = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Error getting user: Missing name."

  argumenta.storage.getUsersWithMetadata [name], (err, users) ->
    return res.notFound "User '#{name}' not found." if err or !users.length
    return res.reply 'users/user', user: users[0]

# Show public overview of a user, including repos
exports.public = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Username missing."

  argumenta.users.get name, (err, user) ->
    return res.notFound "User '#{name}' not found." if err

    argumenta.publications.byUsernames [name], {}, (err, publications) ->
      if err
        return res.failed '/', "Failed loading publications for user '#{name}'.",
          status: Errors.statusFor err
      else
        user.publications = publications
        return res.reply 'users/public',
          user: user
