
# Globals middleware extends res.locals with the given properties
# to simulate global variables in template views.
#
# Example:
#
#     app.use middleware.globals { sitename: 'Zombo' }
#
# @param [Object] extensions An object with the global properties.
Globals = (extensions) ->
  globalsFunc = (req, res, next) ->
    res.locals extensions
    next()

module.exports = Globals
