Base      = require '../argumenta/base'
Tag       = require '../argumenta/objects/tag'
Commit    = require '../argumenta/objects/commit'
{inspect} = require 'util'

#
# Tags models a tags collection.  
# It integrates the Storage and Tag modules.
#
class Tags extends Base

  ### Errors ###

  Error: @Error = @Errors.Arguments
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits an Tags instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage] storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Commits a tag for a given user.
  #
  # Example:
  #
  #     tags.commit username, tag, (err, commit) ->
  #       console.log "Committed tag for #{user.username}!" unless err
  #
  # @api public
  # @param [String] username The user's username.
  # @param [Tag] tag The tag to commit.
  # @param [Function] callback(err, commit) Called on error or success.
  # @param [Error] err Any error.
  # @param [Commit] commit The new commit instance.
  commit: (username, tag, callback) ->
    unless tag instanceof Tag and tag.validate()
      err = tag?.validationError or
        new @Error "Valid tag required to create commit.\nGot: #{inspect tag}"
      return callback err, null

    commit = new Commit 'tag', tag.sha1(), username

    @storage.addCommit commit, (err) =>
      return callback err, commit if err
      @storage.addTag tag, (err) =>
        return callback err, null if err
        return callback null, commit

module.exports = Tags
