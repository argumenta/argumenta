
# Argumenta instance
argumenta = require '../app/argumenta'

# Site index
exports.index = (req, res) ->
  argumenta.users.latest {limit: 10}, (err, users) ->
    argumenta.arguments.latest {limit: 20}, (err, args) ->
      res.reply 'index',
        latest_users: users
        latest_arguments: args
