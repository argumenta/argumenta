
argumenta   = require '../app/argumenta'
Errors      = require '../lib/argumenta/errors'
Discussion  = require '../lib/argumenta/discussion'
Comment     = require '../lib/argumenta/comment'

class CommentsRoutes

  # Creates a new comment for an existing discussion.
  @create: (req, res) ->
    unless username = req.session.username
      return res.redirect "/login"

    comment = new Comment
      author:       username
      commentText:  req.param 'comment_text'
      discussionId: req.param 'discussion_id'

    argumenta.comments.add comment, (er1, id) ->
      argumenta.comments.get [id], (er2, comments) ->
        if err = er1 or er2
          return res.failed '/', err.message,
            status: Errors.statusFor err
        else
          comment = comments[0]
          return res.created '/comments/' + comment.commentId,
            "Created a new comment!",
            comment: comment

  # Shows a comment by id.
  @show: (req, res) ->
    id = req.param 'id'
    argumenta.comments.get [id], (err, comments) ->
      if err
        return res.failed '/', err.message,
          status: Errors.statusFor err
      else
        comment = comments[0]
        return res.reply 'comments/show',
          comment: comment

module.exports = CommentsRoutes
