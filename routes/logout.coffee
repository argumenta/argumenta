
# Logout
exports.index = (req, res) ->
  req.session.username = ''
  return res.success '/', "Logged out successfully."
