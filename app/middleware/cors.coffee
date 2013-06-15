
# This middleware configures CORS headers.
#
# Specify the allowed origin and methods:
#
#     app.use middleware.cors( origin: "*", methods: "GET,PUT,POST" )
#
# @param [Object] options
# @param [String] options.origin
# @param [String] options.methods
# @return [Function] The middleware.
CORS = (options) ->
  origin  = options.origin ? ''
  methods = options.methods ? ''
  return (req, res, next) ->
    res.set('Access-Control-Allow-Origin', origin)
    res.set('Access-Control-Allow-Methods', methods)
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    next()

module.exports = CORS
