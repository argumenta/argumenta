_ = require 'underscore'

# Failed middleware adds a res.failed helper.
#
# The failed helper responds with a 302 redirect for browsers,
# or sends json with a default status of 400 (Bad Request) if
# the format is 'json' or 'jsonp'.
#
# Middleware Example:
#
#     # Failed depends on reply middleware
#     app.use reply()
#     app.use failed()
#
# Helper Example:
#
#     res.failed "/login", "Incorrect login.", status: 401
#
# Middleware Options:
#
# Helper Options:
#     - url: The redirect url for browsers.
#     - error: An error message.
#     - options: An options hash to pass to the reply helper.
Failed = () ->
  return (req, res, next) ->
    res.failed = (url, error, options) ->
      options = _.extend {url, error, status: 400}, options
      format  = req.param 'format'
      if format is 'json' or format is 'jsonp'
        res.reply 'index', options
      else
        req.flash 'errors', error
        res.redirect url
    next()

module.exports = Failed
