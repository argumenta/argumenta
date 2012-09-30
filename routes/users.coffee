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
  {username, password, email} = req.body

  argumenta.users.create username, password, email, (err, user) ->
    if err
      return res.failed '/join', err.message,
        status: Errors.statusFor err
    else
      req.session.username = username
      return res.created "/users/#{user.username}",
        "Welcome aboard, #{user.username}!",
        user: user

# Show a user as html or json
exports.show = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Error getting user: Missing name."

  argumenta.storage.getUser name, (err, user) ->
    return res.notFound "User '#{name}' not found" if err
    return res.reply 'users/user', user: user

# Show public overview of a user, including repos
exports.public = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Username missing."

  argumenta.storage.getUser name, (err, user) ->
    return res.notFound "User '#{name}' not found." if err

    keys = ( [name, reponame] for reponame, hash of user.repos )
    argumenta.storage.getRepos keys, (err, repos) ->
      return res.notFound "Repos not found for user '#{name}'." if err
      return res.reply 'users/public',
        user: user,
        repos: repos
