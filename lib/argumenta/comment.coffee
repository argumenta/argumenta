_       = require 'underscore'
User    = require '../../lib/argumenta/user'
Errors  = require '../../lib/argumenta/errors'

#
# Comment models a post by a user within a discussion.
#
class Comment

  @ValidationError = Errors.Validation

  # The character limit for comment text.
  @MAX_COMMENT_LENGTH = 2400

  # Creates a comment instance.
  #
  # @api public
  # @param [Object]         params
  # @param [Number]         params.commentId
  # @param [String]         params.author
  # @param [Date]           params.commentDate
  # @param [String]         params.commentText
  # @param [Number]         params.discussionId
  constructor: (params) ->
    @commentId     = params.commentId ? params.comment_id
    @author        = params.author
    @commentDate   = params.commentDate ? params.comment_date
    @commentText   = params.commentText ? params.comment_text
    @discussionId  = params.discussionId ? params.discussion_id

  # Gets a plain object with comment data.
  #
  # @api public
  # @return [Object] The comment data.
  data: () ->
    data = {
      comment_id     : @commentId
      author         : @author
      comment_date   : @commentDate
      comment_text   : @commentText
      discussion_id  : @discussionId
    }
    return data

  ### Validation ###

  # Validates the comment instance.
  #
  #     isValid = comment.validate()
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      if @validateCommentId() and @validateAuthor() and
         @validateCommentDate() and @validateCommentText() and
         @validateDiscussionId()
        @validationError = null
        @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  ### Instance Validation ###

  validateCommentId: () ->
    return Comment.validateCommentId @commentId

  validateAuthor: () ->
    return Comment.validateAuthor @author

  validateCommentDate: () ->
    return Comment.validateCommentDate @commentDate

  validateCommentText: () ->
    return Comment.validateCommentText @commentText

  validateDiscussionId: () ->
    return Comment.validateDiscussionId @discussionId

  ### Static Validation ###

  @validateCommentId: (commentId) ->
    unless commentId?
      return true

    unless _.isNumber commentId
      throw new @ValidationError "Comment id must be an integer, if set."

    return true

  @validateAuthor: (author) ->
    try
      User.validateUsername author
    catch err
      throw new @ValidationError "Comment author must be valid."

    return true

  @validateCommentDate: (commentDate) ->
    unless _.isDate commentDate
      throw new @ValidationError "Comment date must be a valid date."

    return true

  @validateCommentText: (commentText) ->
    unless _.isString commentText
      throw new @ValidationError "Comment text must be a string."

    unless commentText.length > 0
      throw new @ValidationError "Comment text must not be empty."

    unless commentText.length <= @MAX_COMMENT_LENGTH
      throw new @ValidationError """
        Comment text must be #{@MAX_COMMENT_LENGTH} characters or less."""

    return true

  @validateDiscussionId: (discussionId) ->
    unless _.isNumber discussionId
      throw new @ValidationError "Comment discussion id must be an integer."

    return true

module.exports = Comment
