
argumenta   = require '../app/argumenta'
Errors      = require '../lib/argumenta/errors'
Discussion  = require '../lib/argumenta/discussion'
Comment     = require '../lib/argumenta/comment'

class DiscussionsRoutes

  # Creates a new discussion via POST.
  @create: (req, res) ->
    unless username = req.session.username
      if /\.json/.test req.path
        return res.failed "/", "Login to create discussions.", 401
      else
        return res.redirect "/login"

    comment = new Comment
      author:      username
      commentText: req.param 'comment_text'

    discussion = new Discussion
      targetType:  req.param 'target_type'
      targetSha1:  req.param 'target_sha1'
      creator:     username
      createdAt:   new Date()
      comments: [
        comment
      ]

    argumenta.discussions.add discussion, (er1, id) ->
      argumenta.discussions.get [id], (er2, discussions) ->
        if err = er1 or er2
          return res.failed '/', err.message,
            status: Errors.statusFor err
        else
          discussion = discussions[0]
          return res.created '/discussions/' + discussion.discussionId,
            "Created a new discussion!",
            discussion: discussion

  # Shows a discussion by id.
  @show: (req, res) ->
    id = req.param 'id'
    argumenta.discussions.get [id], (err, discussions) ->
      if err
        return res.failed '/', err.message,
          status: Errors.statusFor err
      else
        discussion = discussions[0]
        return res.reply 'discussions/show',
          discussion: discussion

module.exports = DiscussionsRoutes
