_           = require 'underscore'
Base        = require '../argumenta/base'
Comment     = require '../argumenta/comment'

#
# Comments models a comments collection.  
# It integrates the Storage and Comment modules.
#
class Comments extends Base

  ### Errors ###

  Error: @Error = @Errors.Comment
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits a Comments instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Adds a given comment to an existing discussion.
  #
  #     comments.add comment, (err, id) ->
  #       console.log "Saved comment #{id}!" unless err
  #
  # @api public
  # @param [Comment]     comment
  # @param [Function]    callback(err, id)
  # @param [Error]       err
  # @param [Number]      id
  add: (comment, callback) ->
    unless comment instanceof Comment and comment.validate()
      err = comment?.validationError or
        new @Error "Valid comment required to add comment."
      return callback err, null

    @storage.addComment comment, (err, commentId) =>
      return callback err if err
      return callback null, commentId

  # Gets comment resources by ids.
  #
  # @api public
  # @param [Array<Number>]      ids
  # @param [Function]           callback(err, comments)
  # @param [Error]              err
  # @param [Array<Comment>]     comments
  get: (ids, callback) ->
    unless _.isArray ids
      return new @Error "Ids must be an array."

    if ids.length is 0
      return callback null, []

    @storage.getComments ids, (err, comments) =>
        if err
          return callback new @Error "Failed getting comments."
        else
          return callback null, comments

module.exports = Comments
