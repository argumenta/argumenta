_           = require 'underscore'
Base        = require '../../argumenta/base'
Commit      = require '../../argumenta/objects/commit'
Proposition = require '../../argumenta/objects/proposition'

#
# Publications models a publications collection.  
# It integrates the Storage, User, Argument, and Proposition modules.
#
class Publications extends Base

  ### Errors ###

  Error: @Error = @Errors.Publications
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits a Publications instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Gets latest publications for given usernames.
  #
  # @api public
  # @param [Object]             options
  # @param [Number]             options.limit
  # @param [Number]             options.offset
  # @param [Function]           callback(err, publications)
  # @param [Error]              err
  # @param [Array<Publication>] publications
  byUsernames: (usernames, options, callback) ->
    @storage.store.listPublications usernames, options, (err, hashes) =>
      return callback err if err
      @get hashes, (err, publications) =>
        return callback null, publications

  # Gets publications by hashes.
  #
  # @api public
  # @param [Array<String>]      hashes
  # @param [Function]           callback(err, publications)
  # @param [Error]              err
  # @param [Array<Publication>] publications
  get: (hashes, callback) ->
    unless _.isArray hashes
      return callback new @Error "Hashes must be an array."

    if hashes.length is 0
      return callback null, []

    @argumenta.arguments.get hashes, (er1, args) =>
      @argumenta.propositions.get hashes, (er2, props) =>
        if er1 instanceof @Errors.NotFound then er1 = null; args = []
        if er2 instanceof @Errors.NotFound then er2 = null; props = []
        return callback err if err = er1 or er2

        byHash = {}
        byHash[pub.sha1()] = pub for pub in [].concat args, props
        publications = (pub for hash in hashes when pub = byHash[hash])
        return callback null, publications

module.exports = Publications
