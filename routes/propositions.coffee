# Argumenta instance, Errors, and Proposition classes
argumenta   = require '../app/argumenta'
Errors      = require '../lib/argumenta/errors'
Proposition = require '../lib/argumenta/objects/proposition'

# Show page for creating a new proposition
exports.new = (req, res) ->
  unless username = req.session.username
    return res.redirect "/login"

  params = req.flash('propositions')[0] or {
    text: ''
  }

  placeholder = {
    text: 'My proposition...'
  }

  return res.reply "propositions/new",
    proposition: new Proposition(params.text)
    placeholder: new Proposition(placeholder.text)

# Create a new proposition via POST.
exports.create = (req, res) ->
  unless username = req.session.username
    req.cookies.proposition = req.body
    return res.failed "/login", "Login to publish propositions.",
      status: 401

  text = req.param('text') or ''
  proposition = new Proposition(text)

  argumenta.propositions.commit username, proposition, (err, commit) ->
    if err
      return res.failed '/propositions/new', err.message,
        status: Errors.statusFor err
    else
      return res.created '/propositions/' + proposition.sha1(),
        "Created a new proposition!", {proposition}

# Show a proposition as html, json, or jsonp
exports.show = (req, res) ->
  hash = req.param 'hash'

  argumenta.storage.getPropositionsWithMetadata [hash], (err, props) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err

    if proposition = props[0]
      return res.reply "propositions/show", {proposition}
    else
      return res.reply 'index',
        error: "Proposition '#{hash}' not found.",
        status: 404

# Show proposition tags as html, json, or jsonp
exports.tags = (req, res) ->
  hash = req.param 'hash'

  targets = [hash]
  argumenta.storage.getTagsFor targets, (err, tags) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err
    else
      return res.reply "propositions/tags", {tags}

# Show proposition tags plus sources as html, json, or jsonp
exports.tagsPlusSources = (req, res) ->
  hash = req.param 'hash'

  targets = [hash]
  argumenta.storage.getTagsPlusSources targets, (err, tags, sources, commits) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err
    else
      return res.reply "propositions/tags", {tags, sources, commits}
