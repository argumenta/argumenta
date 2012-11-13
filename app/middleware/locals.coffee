_ = require 'underscore'

# Locals middleware extends res.locals on each request
# to provide local variables in template views.
#
# Example:
#
#     app.use middleware.locals (req, res) ->
#       return extensions = {
#         username: req.session('username')
#         messages: req.flash('messages')
#       }
#
# @param [Function] extensions(req, res) Generates locals for each request.
Locals = (extensions) ->
  localsFunc = (req, res, next) ->
    vals = if _.isFunction( extensions ) then extensions(req, res) else extensions
    res.locals vals
    next()

module.exports = Locals
