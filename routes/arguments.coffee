# Argumenta instance, Argument, Storage and Errors classes
argumenta = require '../app/argumenta'
Argument  = require '../lib/argumenta/objects/argument'
Storage   = require '../lib/argumenta/storage'
Errors    = require '../lib/argumenta/errors'

# Show page for creating a new argument
exports.new = (req, res) ->
  unless username = req.session.username
    return res.redirect "/login"

  params = req.flash('arguments')[0] or {
    title: '',
    premises: ['', ''],
    conclusion: ''
  }

  placeholder = {
    title: 'The Argument Title'
    premises: ['A brief proposition or claim.', '']
    conclusion: 'A concluding proposition.'
  }

  return res.reply "arguments/new",
    argument: new Argument(params),
    placeholder: new Argument(placeholder)

# Create an argument via POST
exports.create = (req, res) ->
  {title, premises, conclusion} = req.body

  unless username = req.session.username
    req.cookies.argument = req.body
    return res.redirect "/login"

  argument = new Argument title, premises, conclusion

  argumenta.arguments.commit username, argument, (err, commit) ->
    if err
      req.flash 'arguments', argument.data()
      req.flash 'errors', err.message
      res.status Errors.statusFor err
      res.redirect "/arguments/new"
    else
      repo = argument.repo()
      return res.redirect "/#{username}/#{repo}"

# Show an argument as html, json, or jsonp
exports.show = (req, res) ->
  hash = req.param 'hash'
  unless hash
    return res.reply 'index', error: "Error getting argument: missing hash."

  argumenta.storage.getArgument hash, (err, arg) ->
    if err
      return res.reply 'index',
        error: err.message,
        status: Errors.statusFor err
    else
      return res.reply 'arguments/show',
        argument: arg