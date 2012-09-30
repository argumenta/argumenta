_ = require 'underscore'

# Success middleware adds a res.success helper.
#
# The success helper responds with a 302 redirect for browsers,
# or sends json with a 200 (OK) status if the format is 'json' or 'jsonp'.
#
# Middleware Example:
#
#     # Success depends on reply middleware
#     app.use reply()
#     app.use success()
#
# Helper Example:
#
#     res.success "/#{username}", "Welcome back, #{username}!"
#
# Middleware Options:
#
# Helper Options:
#     - url: The redirect url for browsers.
#     - message: A success message.
#     - options: An options hash to pass to the reply helper.
Success = () ->
  return (req, res, next) ->
    res.success = (url, message, options) ->
      options = _.extend {url, message, status: 200}, options
      format  = req.param 'format'
      if format is 'json' or format is 'jsonp'
        res.reply 'index', options
      else
        req.flash 'messages', message
        res.redirect url
    next()

module.exports = Success
