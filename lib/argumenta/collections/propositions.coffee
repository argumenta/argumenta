_           = require 'underscore'
Base        = require '../../argumenta/base'
Commit      = require '../../argumenta/objects/commit'
Proposition = require '../../argumenta/objects/proposition'

#
# Propositions models a propositions collection.  
# It integrates the Storage and Proposition modules.
#
class Propositions extends Base

  ### Errors ###

  Error: @Error = @Errors.Propositions

  ### Constructor ###

  # Inits a Propositions instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Commits a proposition for a given user.
  #
  #     propositions.commit username, proposition, (err, commit) ->
  #       console.log "Committed proposition for #{username}!" unless err
  #
  # @api public
  # @param [String]      username
  # @param [Proposition] proposition
  # @param [Function]    callback(err, commit)
  # @param [Error]       err
  # @param [Commit]      commit
  commit: (username, proposition, callback) ->
    unless proposition instanceof Proposition and proposition.validate()
      err = proposition?.validationError or
        new @Error "Valid proposition required to create commit."
      return callback err, null

    commit = new Commit
      targetType: 'proposition'
      targetSha1: proposition.sha1()
      committer:  username
      parents:    null
      host:       @argumenta.options.host

    @storage.addPropositions [proposition], (err) =>
      return callback err if err
      @storage.addCommit commit, (err) =>
        return callback err if err
        return callback null, commit

  # Gets proposition resources by hashes.
  #
  # @api public
  # @param [Array<String>]      hashes
  # @param [Function]           callback(err, propositions)
  # @param [Error]              err
  # @param [Array<Proposition>] propositions
  get: (hashes, callback) ->
    unless _.isArray hashes
      return new @Error "Hashes must be an array."

    if hashes.length is 0
      return callback null, []

    @storage.getPropositionsWithMetadata hashes, (er1, props) =>
      @storage.getCommitsFor hashes, (er2, commits) =>
        if err = er1 or er2
          return callback new @Error "Failed getting propositions and commits."

        if hashes.length and !props.length
          return callback new @Errors.NotFound "Propositions not found."

        byHash = {}
        for prop in props
          byHash[prop.sha1()] = prop
        for commit in commits
          byHash[commit.targetSha1]?.commit = commit

        results = []
        for hash in hashes
          if prop = byHash[hash]
            results.push prop

        return callback null, results

  # Gets latest propositions.
  #
  # @api public
  # @param [Object]             options
  # @param [Number]             options.limit
  # @param [Number]             options.offset
  # @param [Function]           callback(err, propositions)
  # @param [Error]              err
  # @param [Array<Proposition>] propositions
  latest: (options, callback) ->

    @storage.store.listPropositions options, (err, sha1s) =>
      return callback new @Error "Latest proposition sha1s not found." if err
      return callback null, [] if sha1s.length is 0

      @get sha1s, (err, props) =>
        return callback new @Error "Latest propositions not found." if err
        return callback null, props

module.exports = Propositions
