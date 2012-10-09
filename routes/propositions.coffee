# Argumenta instance, Tag and Errors classes
argumenta = require '../app/argumenta'
Errors    = require '../lib/argumenta/errors'

# Show a proposition as html, json, or jsonp
exports.show = (req, res) ->
  hash = req.param 'hash'

  argumenta.storage.getProposition hash, (err, proposition) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err
    else
      return res.reply "propositions/show", {proposition}

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
