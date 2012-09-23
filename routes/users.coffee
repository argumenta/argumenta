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
      return res.reply 'index',
        error: err.message,
        status: Errors.statusFor err
    else
      req.session.username = username
      req.flash 'message', "Welcome aboard, #{user.username}!"
      return res.redirect "/users/#{user.username}"

# Show a user as html or json
exports.show = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Error getting user: Missing name."

  argumenta.storage.getUser name, (err, user) ->
    return res.reply 'index', error: "User '#{name}' not found.", status: 404 if err
    return res.reply 'users/user', user: user

# Show public overview of a user, including repos
exports.public = (req, res) ->
  name = req.param 'name'
  unless name?
    return res.reply 'index', error: "Username missing."

  argumenta.storage.getUser name, (err, user) ->
    return res.reply 'index', error: "User '#{name}' not found.", status: 404 if err

    keys = ( [name, reponame] for reponame, hash of user.repos )
    argumenta.storage.getRepos keys, (err, repos) ->
      if err
        return res.reply 'index',
          error: "Repos not found for user '#{name}'.",
          status: 404
      else
        toData = (repo) ->
          return {
            username: repo.username
            reponame: repo.reponame
            user:     repo.user.data()
            commit:   repo.commit.data()
            target:   repo.target.data()
          }

        if /^json/.test req.param 'format'
          user = user.data()
          repos = repos.map (repo) -> toData(repo)

        return res.reply 'users/public',
          user: user,
          repos: repos
