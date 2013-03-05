Auth      = require '../lib/argumenta/auth'
argumenta = require '../app/argumenta'

# Show the login page
exports.index = (req, res) ->
  return res.reply 'login'

# Login via POST
exports.verify = (req, res) ->

  params =
    username: req.param 'username'
    password: req.param 'password'

  argumenta.auth.verifyLogin params.username, params.password, (err, result) ->
    if err
      req.flash 'username', params.username
      res.failed "/login", "Error verifying login.",
        status: 401
    else
      if result
        req.session.username = params.username
        res.success "/#{params.username}",
          "Welcome back, #{params.username}"
      else
        req.flash 'username', params.username
        res.failed "/login", "Invalid username and password combination.",
          status: 401
