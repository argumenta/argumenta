_         = require 'underscore'
Base      = require '../argumenta/base'

#
# Search allows querying for user and object resources.  
#
class Search extends Base

  ### Errors ###

  Error: @Error = @Errors.Search
  StorageConflictError: @StorageConflictError = @Errors.StorageConflict
  StorageError: @StorageError = @Errors.Storage

  ### Constructor ###

  # Inits a Search instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage] storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Queries for user, arguments and propositions.
  #
  #     storage.search "Chelsea Manning", {}, (err, results) ->
  #       console.log results.arguments unless err
  #
  # @api public
  # @param [String]             query
  # @param [Object]             options
  # @param [Function]           cb(err, results)
  # @param [Object]             results
  # @param [Array<PublicUser>]  results.users
  # @param [Array<Argument>]    results.arguments
  query: (query, options={}, callback) ->
    options.return_keys = true
    @storage.search query, options, (err, results) =>
      return new @Error "Failed searching storage." if err

      @argumenta.arguments.get results.arguments, (err, args) =>
        return callback err if err
        @storage.getUsersWithMetadata results.users, (err, users) =>
          return callback err if err

          resources =
            arguments:    args
            users:        users

          return callback null, resources

module.exports = Search
