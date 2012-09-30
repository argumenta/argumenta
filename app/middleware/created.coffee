_ = require 'underscore'

# Created middleware adds a res.created helper.
#
# The created helper responds with a 302 redirect to the new resource's url,
# or sends json with a 201 (Created) status if the format is 'json' or 'jsonp'.
#
# Middleware Example:
#
#     # Created depends on reply middleware
#     app.use reply()
#     app.use created()
#
# Helper Example:
#
#     res.created "/users/#{username}", "Created an account for '#{username}'!"
#
# Middleware Options:
#
# Helper Options:
#     - url: The new resource's url.
#     - message: A message about the new resource.
#     - options: An options hash to pass to the reply helper.
Created = () ->
  return (req, res, next) ->
    res.created = (url, message, options) ->
      options = _.extend {url, message, status: 201}, options
      format  = req.param 'format'
      if format is 'json' or format is 'jsonp'
        res.reply 'index', options
      else
        req.flash 'messages', message
        res.redirect url
    next()

module.exports = Created
