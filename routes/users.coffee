# Our argumenta instance
argumenta = require '../argumenta.js'

# Users index
exports.index = (req, res) ->
  # Load users from storage, and list them
  argumenta.storage.getAllUsers (err, users) ->
    if err
      console.error 'Error loading users: ' + err
    else
      res.render 'users/index', {title: 'Users', users: users}
