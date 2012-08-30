Base      = require '../argumenta/base'
Argument  = require '../argumenta/objects/argument'
Commit    = require '../argumenta/objects/commit'
{inspect} = require 'util'

#
# Arguments models an arguments collection.  
# It integrates the Storage and Argument modules.
#
class Arguments extends Base

  ### Errors ###

  Error: @Error = @Errors.Arguments
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits an Arguments instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage] storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Commits an argument for a given user.
  #
  # Example:
  #
  #     arguments.commit username, argument, (err, commit) ->
  #       console.log "Committed argument for #{user.username}!" unless err
  #
  # @api public
  # @param [String]   username The user's username.
  # @param [Argument] argument The argument to commit.
  # @param [Function] callback(err, commit) Called on error or success.
  # @param [Error] err Any error.
  # @param [Commit] commit The new commit instance.
  commit: (username, argument, callback) ->
    unless argument instanceof Argument and argument.validate()
      err = new @Error "Valid argument required to create commit.\nGot: #{inspect argument}"
      return callback err, null

    @storage.getRepoHash username, argument.repo(), (err, hash) =>
      parents = []
      parents.push hash if hash
      commit = new Commit 'argument', argument.sha1(), username, null, parents

      @storage.addCommit commit, (err) =>
        return callback err, commit if err
        @storage.addArgument argument, (err) =>
          return callback err, null if err
          @storage.addRepo username, argument.repo(), commit.sha1(), (err) =>
            return callback err, commit

module.exports = Arguments
