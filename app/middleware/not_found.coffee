
# NotFound middleware adds a res.notFound helper.
#
# The notFound helper calls res.reply with an error message,
# the configured view, and a 404 status.
#
# Middleware Example:
#
#     app.use notFound({ view: 'index' });
#
# Helper Example:
#
#     res.notFound( "User " + name + " not found." );
#
# Middleware Options:
#   - options.view: A string naming the 404 view.
#
# Helper Options:
#   - message: A string with the 404 error message.
NotFound = (options) ->
  return (req, res, next) ->
    res.notFound = (message) ->
      res.reply options.view, error: message, status: 404
    next()

module.exports = NotFound
