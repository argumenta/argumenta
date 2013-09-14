_         = require 'underscore'
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
      err = argument?.validationError or
        new @Error "Valid argument required to create commit.\nGot: #{inspect argument}"
      return callback err, null

    @storage.getRepoHash username, argument.repo(), (err, hash) =>
      return callback err, null if err

      commit = new Commit
        targetType: 'argument'
        targetSha1: argument.sha1()
        committer:  username
        parents:    [hash] if hash
        host:       @argumenta.options.host

      @storage.addArgument argument, (err) =>
        return callback err, null if err
        @storage.addCommit commit, (err) =>
          return callback err, commit if err
          @storage.addRepo username, argument.repo(), commit.sha1(), (err) =>
            return callback err, commit

  # Gets argument resources by hashes.
  #
  # @api public
  # @param [Array<String>]   hashes
  # @param [Function]        callback(err, arguments)
  # @param [Error]           err
  # @param [Array<Argument>] arguments
  get: (hashes, callback) ->
    unless _.isArray hashes
      return new @Error "Hashes must be an array."

    if hashes.length is 0
      return callback null, []

    @storage.getArgumentsWithMetadata hashes, (er1, args) =>
      @storage.getCommitsFor hashes, (er2, commits) =>
        if err = er1 or er2
          return callback new @Error "Failed getting arguments and commits." if err

        if hashes.length and !args.length
          return callback new @Errors.NotFound "Arguments not found."

        byHash = {}
        for arg in args
          byHash[arg.sha1()] = arg
        for commit in commits
          byHash[commit.targetSha1].commit = commit

        results = []
        for hash in hashes
          results.push byHash[hash]

        return callback null, results

  # Gets latest arguments.
  #
  # @param [Object]   options
  # @param [Object]   options.limit
  # @param [Object]   options.offset
  # @param [Function] callback(err, args)
  latest: (options, callback) ->

    @storage.store.listArguments options, (err, sha1s) =>
      return callback new @Error "Latest argument sha1s not found." if err
      return callback null, [] if sha1s.length is 0

      @get sha1s, (err, args) =>
        return callback new @Error "Latest arguments not found." if err
        return callback null, args

module.exports = Arguments
