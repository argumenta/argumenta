
# Argumenta instance
argumenta = require '../app/argumenta'

# Site index
exports.index = (req, res) ->
  argumenta.users.latest null, (err, users) ->
    res.reply 'index',
      latest_users: users
