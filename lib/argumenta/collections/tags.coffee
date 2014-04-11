Base      = require '../../argumenta/base'
Tag       = require '../../argumenta/objects/tag'
Commit    = require '../../argumenta/objects/commit'

#
# Tags models a tags collection.  
# It integrates the Storage and Tag modules.
#
class Tags extends Base

  ### Errors ###

  Error: @Error = @Errors.Arguments

  ### Constructor ###

  # Inits an Tags instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Commits a tag for a given user.
  #
  #     tags.commit username, tag, (err, commit) ->
  #       console.log "Committed tag for #{user.username}!" unless err
  #
  # @api public
  # @param [String]   username
  # @param [Tag]      tag
  # @param [Function] callback(err, commit)
  # @param [Error]    err
  # @param [Commit]   commit
  commit: (username, tag, callback) ->
    unless tag instanceof Tag and tag.validate()
      err = tag?.validationError or
        new @Error "Valid tag required to create commit."
      return callback err, null

    commit = new Commit
      targetType: 'tag'
      targetSha1: tag.sha1()
      committer:  username
      host:       @argumenta.options.host

    @storage.addTag tag, (err) =>
      return callback err, null if err
      @storage.addCommit commit, (err) =>
        return callback err, commit if err
        return callback null, commit

module.exports = Tags
