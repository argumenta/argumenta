_         = require 'underscore'
Base      = require '../../argumenta/base'

#
# Repos models a repos collection.  
# It integrates the Storage and Repo modules.
#
class Repos extends Base

  ### Errors ###

  Error: @Error = @Errors.Repos

  ### Constructor ###

  # Inits a Repos instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Gets repo resources by username, reponame key pairs.
  #
  # @api public
  # @param [Array<Array<String>>]   keys
  # @param [Function]               callback(err, repos)
  # @param [Error]                  err
  # @param [Array<Repo>]            repos
  get: (keys, callback) ->
    return callback new @Error "Keys must be an array." unless _.isArray keys
    return callback null, [] if keys.length is 0

    @storage.getRepos keys, (err, repos) =>
      return callback new @Error "Failed getting repos." if err
      return callback new @Error "Repos not found." if repos.length is 0
      return callback null, repos

  # Gets latest repos.
  #
  # @api public
  # @param [Object]          options
  # @param [Number]          options.limit
  # @param [Number]          options.offset
  # @param [Boolean]         options.latest
  # @param [Function]        callback(err, repos)
  # @param [Error]           err
  # @param [Array<Repo>]     repos
  latest: (options, callback) ->

    @storage.store.listRepos options, (err, keys) =>
      return callback new @Error "Latest repo key pairs not found." if err
      return callback null, [] if keys.length is 0

      @get keys, (err, repos) =>
        return callback new @Error "Latest repos not found." if err
        return callback null, repos

module.exports = Repos
