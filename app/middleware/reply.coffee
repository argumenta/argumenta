respond = require '../../routes/helpers/respond'

# Reply middleware adds a res.reply helper.
#
# The reply helper serves data as json, jsonp, and html.
# See respond helper for details.
#
# Middleware Example:
#
#     app.use( reply() );
#
# Helper Examples:
#
#     res.reply('index', {user: user});
#     res.reply('index', {error: "User not found", status: 400 });
#
# Middleware Options:
#   - options.processor: A function to transform options before calling respond.
#
# Helper Options:
#   - view: A string naming the view to respond with.
#   - opts: An options hash for the respond helper.
Reply = (options) ->
  return (req, res, next) ->
    res.reply = (view, opts) ->
      opts = options.processor( opts, req ) if options.processor
      respond( view, opts, req, res )
    next()

module.exports = Reply
