Auth      = require '../../lib/argumenta/auth'
argumenta = require '../../app/argumenta'

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
      req.flash 'errors', "Error verifying login."
      res.redirect '/login'
    else
      if result
        req.session.name = params.username
        req.flash 'messages', "Welcome back, #{params.username}"
        res.redirect "/users/#{params.username}"
      else
        req.flash 'username', params.username
        req.flash 'errors', "Invalid username and password combination."
        res.redirect '/login'
