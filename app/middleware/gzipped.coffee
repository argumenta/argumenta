
# This middleware serves gzipped assets for paths matching `pattern`.
#
# It assumes a compressed version of each asset exists in the static
# directory, with a ".gz" extension.
#
#     app.use gzipped /^\/(js|css|images)/
#     app.use express.static __dirname + '/public'
#
# @param [RegExp] pattern
# @return [Function] The middleware.
Gzipped = (pattern) ->
  return (req, res, next) ->
    if req.url.match pattern
      extension = req.path.match(/\.(\w+)$/)[0]
      res.type extension
      res.set 'Content-Encoding', 'gzip'
      req.url = req.url + '.gz'
    next()

module.exports = Gzipped
