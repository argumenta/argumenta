
# Logout
exports.index = (req, res) ->
  req.session.username = ''
  return res.redirect '/'
