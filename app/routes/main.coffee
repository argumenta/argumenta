respond = require './helpers/respond'

# Site index
exports.index = (req, res) ->
  respond 'index', {}, req, res
