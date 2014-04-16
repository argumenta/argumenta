
# Argumenta instance
argumenta = require '../app/argumenta'

# Site index
exports.index = (req, res) ->
  argumenta.users.latest {limit: 10}, (err, users) ->
    argumenta.repos.latest {limit: 20, metadata: true}, (err, repos) ->
      res.reply 'index',
        latest_users: users
        latest_repos: repos
