_         = require 'underscore'
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
    title: 'My Argument Title'
    premises: ['A brief proposition.', 'Another proposition.']
    conclusion: 'A concluding proposition.'
  }

  _.defaults placeholder.premises, params.premises

  return res.reply "arguments/new",
    argument: new Argument(params),
    placeholder: new Argument(placeholder)

# Edit an argument via GET
exports.edit = (req, res) ->
  unless username = req.session.username
    return res.redirect "/login"

  hash = req.param 'hash'
  unless hash
    return res.reply 'index', error: "Error getting argument: missing hash."

  argumenta.arguments.get [hash], (err, args) ->
   if err
     return res.reply 'index',
       error: err.message,
       status: Errors.statusFor err
   else
     argument = args[0]
     return res.reply 'arguments/edit',
       argument: argument
       placeholder: argument

# Create an argument via POST
exports.create = (req, res) ->
  {title, premises, conclusion} = req.body

  unless username = req.session.username
    req.cookies.argument = req.body
    return res.failed "/login", "Login to publish arguments.",
      status: 401

  argument = new Argument title, premises, conclusion

  argumenta.arguments.commit username, argument, (err, commit) ->
    if err
      if /^json/.test req.param 'format'
        return res.failed '/arguments', err.message,
          status: Errors.statusFor err
      else
        req.flash 'arguments', argument.data()
        return res.failed '/arguments/new', err.message,
          status: Errors.statusFor err
    else
      reponame = encodeURIComponent argument.repo()
      return res.created "/#{username}/#{reponame}",
        "Created a new argument!", {argument}

# Show an argument as html, json, or jsonp
exports.show = (req, res) ->
  hash = req.param 'hash'
  unless hash
    return res.reply 'index', error: "Error getting argument: missing hash."

  argumenta.arguments.get [hash], (err, args) ->
    if err
      return res.reply 'index',
        error: err.message,
        status: Errors.statusFor err
    else
      return res.reply 'arguments/show',
        argument: args[0]

# Get an argument's propositions as html, json, or jsonp
exports.propositions = (req, res) ->
  hash = req.param 'hash'

  argumenta.storage.getArgument hash, (err, argument) ->
    return res.reply 'index', error: err.message, status: Errors.statusFor err if err
    propHashes = argument.propositions.map (prop) -> prop.sha1()

    argumenta.storage.getPropositionsWithMetadata propHashes, (err, propositions) ->
      return res.reply 'index', error: err.message, status: Errors.statusFor err if err
      return res.reply 'arguments/propositions',
        argument: argument
        propositions: propositions

# Get an argument's discussions
exports.discussions = (req, res) ->
  hash = req.param 'hash'

  argumenta.storage.getDiscussionsFor [hash], (err, discussions) ->
    if err
      return res.failed '/', err.message,
        Errors.statusFor err
    else
      return res.reply 'arguments/discussions',
        discussions: discussions
