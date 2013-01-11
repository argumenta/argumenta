# Argumenta instance, Tag and Errors classes
_         = require 'underscore'
argumenta = require '../app/argumenta'
Tag       = require '../lib/argumenta/objects/tag'
Errors    = require '../lib/argumenta/errors'

# Create a tag via POST
exports.create = (req, res) ->
  unless username = req.session.username
    return res.failed "/login", "Login to publish tags.",
      status: 401

  params = _.pick req.body,
    'tag_type',
    'target_type', 'target_sha1',
    'source_type', 'source_sha1',
    'citation_text', 'commentary_text'

  tag = new Tag params

  argumenta.tags.commit username, tag, (err, commit) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err
    else
      return res.created "/tags/#{tag.sha1()}",
        "Created a new tag!", {tag}

# Show a tag as html, json, or jsonp
exports.show = (req, res) ->
  hash = req.param 'hash'

  argumenta.storage.getTag hash, (err, tag) ->
    if err
      return res.failed '/', err.message,
        status: Errors.statusFor err
    else
      if /^json/.test req.param 'format'
        return res.reply 'tags/tag', {tag}
      else
        return res.redirect "#{tag.targetType}s/#{tag.targetSha1}"
