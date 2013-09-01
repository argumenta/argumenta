# Argumenta instance and Error classes
argumenta = require '../app/argumenta'
Errors    = require '../lib/argumenta/errors'

# Search by query for users, arguments, propositions, and tags.
exports.query = (req, res) ->
  query = req.param('query') ? ''
  options =
    offset : req.query.offset

  argumenta.search.query query, options, (err, results) ->
    if err
      return res.failed '/search', err.message,
        status: Errors.statusFor err
    else
      return res.reply 'search',
        results
