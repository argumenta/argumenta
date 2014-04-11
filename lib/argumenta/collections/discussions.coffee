_           = require 'underscore'
Base        = require '../../argumenta/base'
Discussion  = require '../../argumenta/discussion'

#
# Discussions models a discussions collection.  
# It integrates the Storage and Discussion modules.
#
class Discussions extends Base

  ### Errors ###

  Error: @Error = @Errors.Discussions

  ### Constructor ###

  # Inits a Discussions instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Adds a given discussion.
  #
  #     discussions.add discussion, (err, id) ->
  #       console.log "Saved discussion #{id}!" unless err
  #
  # @api public
  # @param [Discussion]  discussion
  # @param [Function]    callback(err, id)
  # @param [Error]       err
  # @param [Number]      id
  add: (discussion, callback) ->
    unless discussion instanceof Discussion and discussion.validate()
      err = discussion?.validationError or
        new @Error "Valid discussion required to add discussion."
      return callback err, null

    @storage.addDiscussion discussion, (er1, discussionId) =>
      comment = discussion.comments[0]
      comment.discussionId = discussionId
      @storage.addComment comment, (er2, commentId) =>
        return callback err if err = er1 or er2
        return callback null, discussionId

  # Gets discussion resources by ids.
  #
  # @api public
  # @param [Array<Number>]      ids
  # @param [Function]           callback(err, discussions)
  # @param [Error]              err
  # @param [Array<Discussion>]  discussions
  get: (ids, callback) ->
    unless _.isArray ids
      return new @Error "Ids must be an array."

    if ids.length is 0
      return callback null, []

    @storage.getDiscussions ids, (err, discussions) =>
      if err
        return callback new @Error "Failed getting discussions."
      else
        return callback null, discussions

module.exports = Discussions
