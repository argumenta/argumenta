_         = require 'underscore'
Base      = require '../../argumenta/base'
Argument  = require '../../argumenta/objects/argument'
Commit    = require '../../argumenta/objects/commit'

#
# Arguments models an arguments collection.  
# It integrates the Storage and Argument modules.
#
class Arguments extends Base

  ### Errors ###

  Error: @Error = @Errors.Arguments

  ### Constructor ###

  # Inits an Arguments instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Commits an argument for a given user.
  #
  #     arguments.commit username, argument, (err, commit) ->
  #       console.log "Committed argument for #{user.username}!" unless err
  #
  # @api public
  # @param [String]   username
  # @param [Argument] argument
  # @param [Function] callback(err, commit)
  # @param [Error]    err
  # @param [Commit]   commit
  commit: (username, argument, callback) ->
    unless argument instanceof Argument and argument.validate()
      err = argument?.validationError or
        new @Error "Valid argument required to create commit."
      return callback err, null

    @storage.getRepoTarget username, argument.repo(), (err, parent, target) =>
      if argument.sha1() is parent?.targetSha1
        return callback null, parent

      parentHash = parent?.sha1()
      commit = new Commit
        targetType:  'argument'
        targetSha1:  argument.sha1()
        committer:   username
        parentSha1s: [parentHash] if parentHash
        host:        @argumenta.options.host

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
      return callback new @Error "Hashes must be an array."

    if hashes.length is 0
      return callback null, []

    @storage.getArgumentsWithMetadata hashes, (er1, args) =>
      @storage.getCommitsFor hashes, (er2, commits) =>
        if err = er1 or er2
          return callback new @Error "Failed getting arguments and commits."

        if hashes.length and !args.length
          return callback new @Errors.NotFound "Arguments not found."

        byHash = {}
        for arg in args
          byHash[arg.sha1()] = arg
        for commit in commits
          byHash[commit.targetSha1]?.commit = commit

        results = []
        for hash in hashes
          if arg = byHash[hash]
            results.push arg

        return callback null, results

  # Gets latest arguments.
  #
  # @param [Object]          options
  # @param [Number]          options.limit
  # @param [Number]          options.offset
  # @param [Function]        callback(err, args)
  # @param [Error]           err
  # @param [Array<Argument>] arguments
  latest: (options, callback) ->

    @storage.store.listArguments options, (err, sha1s) =>
      return callback new @Error "Latest argument sha1s not found." if err
      return callback null, [] if sha1s.length is 0

      @get sha1s, (err, args) =>
        return callback new @Error "Latest arguments not found." if err
        return callback null, args

module.exports = Arguments
