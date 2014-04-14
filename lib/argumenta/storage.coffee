Base        = require '../argumenta/base'
User        = require '../argumenta/user'
Argument    = require '../argumenta/objects/argument'
Proposition = require '../argumenta/objects/proposition'
Commit      = require '../argumenta/objects/commit'
Tag         = require '../argumenta/objects/tag'
Discussion  = require '../argumenta/discussion'
Comment     = require '../argumenta/comment'

# Storage persists users and objects to a backend store.

class Storage extends Base

  # Construction
  # ------------

  # Constructs a new Storage instance, backed by a particular type of store.
  #
  # Create a memory-backed storage instance:
  #
  #     storage = new Storage
  #       storageType: 'local'
  #
  # Create a postgres-backed storage instance:
  #
  #     storage = new Storage
  #       storageType: 'postgres',
  #       storageUrl:  'postgres://user:pass@localhost:5432/db'
  #
  # @param [Object] opts The storage backing options.
  # @param [String] opts.storageType The backing type: 'local' or 'postgres'.
  # @param [String] opts.storageUrl  The backing url, if needed.
  constructor: (opts={}) ->
    {storageType, storageUrl} = opts

    LocalStore = require './storage/local_store'
    PostgresStore = require './storage/postgres_store'

    switch storageType
      when 'local'
        @store = new LocalStore()
      when 'postgres'
        @store = new PostgresStore( storageUrl )
      else
        throw new @Error "Construction error: Invalid storageType: #{storageType}"

  # Errors
  # ------

  # A custom error class for general storage errors.
  Error: @Error = @Errors.Storage

  # Indicates requested resource was not found.
  NotFoundError: @NotFoundError = @Errors.NotFound

  # A storage error indicating a resource conflict,
  # ie, attempts to overwrite existing users or objects.
  ConflictError: @ConflictError = @Errors.StorageConflict

  # Indicates input of bad data for storage.
  InputError: @InputError = @Errors.StorageInput

  # Indicates error retrieving the requested items.
  RetrievalError: @RetrievalError = @Errors.StorageRetrieval

  # Indicates error deleting an item.
  DeletionError: @DeletionError = @Errors.StorageDeletion

  # Instance Methods
  # ----------------

  # Add a user to the store.
  #
  # Only valid users with unique usernames are accepted.
  #
  # Possible errors include:
  #   StorageError, ValidationError, StorageConflictError
  #
  # @param [User]               user
  # @param [Function]           cb(err)
  # @param [Error]              err
  addUser: (user, cb) ->
    unless user instanceof User
      return cb new @Error "User instance required to add user."

    unless user.validate()
      return cb user.validationError

    @store.getUser user.username, (err, prevUser) =>
      return cb new @Errors.StorageConflict "User already exists" if prevUser
      return cb err if err and not err instanceof @Errors.NotFound

      @store.addUser user, (err) ->
        return cb err if err
        return cb null

  # Delete *all* entities from the store.
  #
  # @param [Object]             options
  # @param [Boolean]            options.quick
  # @param [Function]           cb(err)
  # @param [StorageError]       err
  clearAll: (options={}, cb) ->
    @store.clearAll options, (err) ->
      return cb err

  # Get a user by username, omitting sensitive fields.
  #
  # @see getPasswordHash()
  # @param [String]             username
  # @param [Function]           cb(err, user)
  # @param [StorageError]       err
  # @param [PublicUser]         user
  getUser: (username, cb) ->
    @store.getUser username, (err, user) ->
      return cb new @Error "Failed getting user '#{username}'.", err if err
      return cb null, user

  # Get users by usernames, omitting sensitive fields.
  #
  # @param [Array<String>]      usernames
  # @param [Function]           cb(err, users)
  # @param [StorageError]       err
  # @param [Array<PublicUser>]  users
  getUsers: (usernames, cb) ->
    @store.getUsers usernames, (err, users) ->
      return cb new @Error "Failed getting users from store." if err
      return cb null, users

  # Get metadata for users by usernames.
  #
  # @param [Array<String>]      usernames
  # @param [Function]           cb(err, metadata)
  # @param [StorageError]       err
  # @param [Array<Object>]      metadata
  getUsersMetadata: (usernames, cb) ->
    @store.getUsersMetadata usernames, (err, metadata) ->
      return cb new @Error "Failed getting users metadata from store." if err
      return cb null, metadata

  # Get users with metadata by usernames, omitting sensitive fields.
  #
  # @param [Array<String>]      usernames
  # @param [Function]           cb(err, users)
  # @param [StorageError]       err
  # @param [Array<PublicUser>]  users
  getUsersWithMetadata: (usernames, cb) ->
    @store.getUsers usernames, (er1, users) =>
      @store.getUsersMetadata usernames, (er2, metadata) =>
        if err = er1 or er2
          return cb new @Error "Failed getting users with metadata from store."
        byUsername = {}
        for m in metadata
          byUsername[m.username] = m
        for u in users
          u.metadata = byUsername[u.username]
        return cb null, users

  # Get repos for a given user.
  #
  # @param [String]             username
  # @param [Object]             options
  # @param [Number]             options.limit  (Default: 50)
  # @param [Number]             options.offset (Default: 0)
  # @param [Boolean]            options.latest (Default: true)
  getUserRepos: (username, options, cb) ->
    @store.getUserRepos username, options, (err, repos) ->
      return cb new @Error "Failed getting user repos for '#{username}'", err if err
      return cb null, repos

  # Get a user's password hash.
  #
  # @param [String]             username
  # @param [Function]           cb(err, hash)
  # @param [StorageError]       err
  # @param [String]             hash
  getPasswordHash: (username, cb) ->
    @store.getPasswordHash username, (err, hash) ->
      return cb new @Error("Failed getting user: "  + username, err) if err
      return cb null, hash

  # Get an array of all users, omitting sensitive fields.
  #
  # @param [Function]           cb(err, users)
  # @param [StorageError]       err
  # @param [Array<Object>]      users
  getAllUsers: (cb) ->
    @store.listUsers (er1, usernames) =>
      @getUsersWithMetadata usernames, (er2, users) =>
        if err = er1 or er2
          return cb new @Error "Failed getting all users from store."
        return cb null, users

  #### Repos ####

  # Add a user repo for a given commit hash.
  #
  # @param [String]             username
  # @param [String]             reponame
  # @param [Function]           callback
  # @param [Error]              err
  # @param [String]             commitHash
  addRepo: (username, reponame, commitHash, callback) ->
    @getUser username, (err, user) =>
      if err or not user
        return callback new @NotFoundError "User required to create repo. Got: #{user}"
      @store.addRepo username, reponame, commitHash, (err) ->
        return callback err

  # Delete a repo by owner and name.
  #
  # @param [String]             username
  # @param [String]             reponame
  # @param [Function]           cb(err)
  # @param [Error]              err
  deleteRepo: (username, reponame, cb) ->
    @store.deleteRepo username, reponame, (err) =>
      if err
        message = "Error deleting repo '#{username}/#{reponame}'."
        return cb new @DeletionError message, err
      else
        return cb null

  # Get the commit hash for a given user repo.
  #
  #     storage.getRepoHash username, repo, (err, hash) ->
  #       console.log "This repo points to commit: #{hash}!"
  #
  # @param [String]             username
  # @param [String]             reponame
  # @param [Function]           callback
  # @param [Error]              err
  # @param [String]             commitHash
  getRepoHash: (username, reponame, callback) ->
    @store.getRepoHash username, reponame, (err, hash) ->
      return callback null, hash

  # Get the commit and target for a given user repo.
  #
  #     storage.getRepoTarget name, repo, (err, commit, target) ->
  #       console.log "Got repo for commit: #{commit.sha1()}\n"
  #                   "with target: #{target.sha1()}"
  #
  # @param [String]             username
  # @param [String]             reponame
  # @param [Function]           cb(err, commit, target)
  # @param [Error]              err
  # @param [Commit]             commit
  # @param [Argument]           target
  getRepoTarget: (username, reponame, cb) ->
    @getRepoHash username, reponame, (er1, hash) =>
      @getCommit hash, (er2, commit) =>
        @getArgument commit.targetSha1, (er3, argument) =>
          err = er1 or er2 or er3
          return cb err if err
          return cb null, commit, argument

  # Get the repo for each [username, reponame] key pair.
  #
  #     key1 = [ 'user1', 'repo-a' ]
  #     key2 = [ 'user2', 'repo-b' ]
  #     key3 = [ 'user3', 'repo-c' ]
  #
  #     keys = [ key1, key2, key3 ]
  #
  #     storage.getRepos keys, (err, repos) ->
  #       console.log "Got repos: ", repos
  #
  # @param [Array<Array<String>>] keys
  # @param [Function]             cb(err, repos)
  # @param [StorageError]         err
  # @param [Array<Repo>]          repos
  getRepos: (keys, cb) ->
    @store.getRepos keys, (err, repos) ->
      return cb err if err
      return cb null, repos

  #### Objects ####

  # Add an argument to the store.
  #
  # @param [Argument]           argument
  # @param [Function]           cb(err)
  # @param [StorageError]       err
  addArgument: (argument, cb) ->
    unless argument instanceof Argument
      return cb new @InputError "Argument instance required to store argument."
    unless argument.validate()
      return cb new @InputError "Argument to store must be valid."

    @store.addArgument argument, cb

  # Get an argument from the store by hash.
  #
  # @param [String]             hash
  # @param [Function]           cb(err, args)
  # @param [StorageError]       err
  # @param [Argument]           arg
  getArgument: (hash, cb) ->
    @store.getArguments [hash], (err, args) =>
      return cb new @RetrievalError "Failed getting arguments from the store." if err
      return cb new @NotFoundError "Argument '#{hash}' not found." unless args.length > 0
      return cb null, args[0]

  # Get arguments from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Object]             options
  # @param [Boolean]            options.metadata
  # @param [Function]           cb(err, args)
  # @param [StorageError]       err
  # @param [Array<Argument>]    args
  getArguments: (hashes, options..., cb) ->
    options = options[0] ? {}
    return @getArgumentsWithMetadata hashes, cb if options.metadata

    @store.getArguments hashes, (err, args) =>
      return cb new @RetrievalError "Failed getting arguments from the store." if err
      return cb null, args

  # Get arguments along with metadata from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Function]           cb(err, args)
  # @param [StorageError]       err
  # @param [Array<Argument>]    args
  getArgumentsWithMetadata: (hashes, cb) ->
    @store.getArguments hashes, (err, args) =>
      return cb new @RetrievalError "Failed getting arguments from the store." if err

      propHashes = []
      for a in args
        for p in a.propositions
          propHashes.push p.sha1()

      @store.getPropositionsMetadata propHashes, (err, propMetadata) =>
        return cb new @RetrievalError "Failed getting propositions metadata." if err

        byHash = {}
        for md in propMetadata
          byHash[md.sha1] = md
        for a in args
          for p in a.propositions
            p.metadata = byHash[p.sha1()]

        return cb null, args

  # Add an array of propositions to the store.
  #
  # @param [Array<Proposition>] propositions
  # @param [Function]           cb(err)
  # @param [StorageError]       err
  addPropositions: (propositions, cb) ->
    for p in propositions
      unless p instanceof Proposition
        return cb new @Error("Won't add non-proposition: " + p)
      unless p.validate()
        return cb new @Error("Won't add invalid proposition: " + p)

    @store.addPropositions propositions, (err) ->
      return cb new @Error "Failed adding propositions to the store." if err
      return cb null

  # Get a proposition from the store by hash.
  #
  # @param [String]             hash
  # @param [Function]           cb(err, proposition)
  # @param [StorageError]       err
  # @param [Proposition]        proposition
  getProposition: (hash, cb) ->
    @store.getPropositions [hash], (err, propositions) =>
      return cb new @RetrievalError "Failed getting proposition from the store." if err
      return cb new @NotFoundError "Proposition '#{hash}' not found." unless propositions.length > 0
      return cb null, propositions[0]

  # Get propositions from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Object]             options
  # @param [Boolean]            options.metadata
  # @param [Function]           cb(err, propositions)
  # @param [StorageError]       err
  # @param [Array<Proposition>] propositions
  getPropositions: (hashes, options..., cb) ->
    options = options[0] ? {}
    return @getPropositionsWithMetadata hashes, cb if options.metadata

    @store.getPropositions hashes, (err, propositions) ->
      return cb new @Error "Failed getting propositions from the store." if err
      return cb null, propositions

  # Get propositions metadata from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Function]           cb(err, propositions)
  # @param [StorageError]       err
  # @param [Array<Object>]      metadata
  getPropositionsMetadata: (hashes, cb) ->
    @store.getPropositionsMetadata hashes, (err, metadata) ->
      return cb new @Error "Failed getting propositions metadata from the store." if err
      return cb null, metadata

  # Get propositions (along with metadata) from the store by hashes.
  #
  # @param [Array<String>]       hashes
  # @param [Function]            cb(err, propositions)
  # @param [StorageError]        err
  # @param [Array<Proposition>]  propositions
  getPropositionsWithMetadata: (hashes, cb) ->
    @store.getPropositions hashes, (er1, propositions) =>
      @store.getPropositionsMetadata hashes, (er2, metadata) =>
        if err = er1 or er2
          return cb new @Error "Failed getting propositions from the store."
        metadataBySha1 = {}
        metadataBySha1[data.sha1] = data for data in metadata
        prop.metadata = metadataBySha1[prop.sha1()] for prop in propositions
        return cb null, propositions

  # Add a commit to the store.
  #
  # @param [Commit]             commit
  # @param [Function]           cb(err)
  # @param [StorageError]       err
  addCommit: (commit, cb) ->
    unless commit instanceof Commit
      return cb new @InputError "Commit instance required to store commit."
    unless commit.validate()
      return cb new @InputError "Commit to store must be valid."

    @store.addCommit commit, (err) ->
      return cb new @Error "Failed storing commit.", err if err
      return cb null

  # Get a commit from the store by hash.
  #
  # @param [String]             hash
  # @param [Function]           cb(err, commit)
  # @param [StorageError]       err
  # @param [Commit]             commit
  getCommit: (hash, cb) ->
    @store.getCommits [hash], (err, commits) =>
      return cb new @RetrievalError "Failed getting commit from the store." if err
      return cb new @NotFoundError "Commit '#{hash}' not found." unless commits.length > 0
      return cb null, commits[0]

  # Get commits from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Function]           cb(err, commits)
  # @param [StorageError]       err
  # @param [Array<Commit>]      commits
  getCommits: (hashes, cb) ->
    @store.getCommits hashes, (err, commits) ->
      return cb new @RetrievalError "Failed getting commits from the store." if err
      return cb null, commits

  # Get commits from the store with given target hashes.
  #
  # @param [Array<String>]      targetHashes
  # @param [Function]           cb(err, commits)
  # @param [StorageError]       err
  # @param [Array<Commits>]     commits
  getCommitsFor: (targetHashes, cb) ->
    @store.getCommitsFor targetHashes, (err, commits) ->
      return cb new @RetrievalError "Failed getting commits from the store." if err
      return cb null, commits

  # Add a tag to the store.
  #
  # @param [Tag]                tag
  # @param [Function]           cb(err)
  # @param [StorageError]       err
  addTag: (tag, cb) ->
    unless tag instanceof Tag
      return cb new @InputError "Tag instance required to store tag."
    unless tag.validate()
      return cb new @InputError "Tag to store must be valid."

    @store.addTag tag, cb

  # Get a tag from the store by hash.
  #
  # @param [String]             hash
  # @param [Function]           cb(err, tag)
  # @param [StorageError]       err
  # @param [Tag]                tag
  getTag: (hash, cb) ->
    @store.getTags [hash], (err, tags) =>
      return cb new @RetrievalError "Failed getting tag from the store." if err
      return cb new @NotFoundError "Tag '#{hash}' not found." unless tags.length > 0
      return cb null, tags[0]

  # Get tags from the store by hashes.
  #
  # @param [Array<String>]      hashes
  # @param [Function]           cb(err, tags)
  # @param [StorageError]       err
  # @param [Array<Tag>]         tags
  getTags: (hashes, cb) ->
    @store.getTags hashes, (err, tags) ->
      return cb new @RetrievalError "Failed getting tags from the store." if err
      return cb null, tags

  # Get tags from the store with given target hashes.
  #
  # @param [Array<String>]      targetHashes
  # @param [Function]           cb(err, tags)
  # @param [StorageError]       err
  # @param [Array<Tag>]         tags
  getTagsFor: (targetHashes, cb) ->
    @store.getTagsFor targetHashes, (err, tags) ->
      return cb new @RetrievalError "Failed getting tags from the store." if err
      return cb null, tags

  # Get tags (plus any source objects) from the store for given target hashes.
  #
  # Commits for all tags and sources are also retrieved.
  #
  # @param [Array<String>]      targetHashes
  # @param [Function]           cb(err, tags, sources, commits)
  # @param [StorageError]       err
  # @param [Array<Tag>]         tags
  # @param [Array<Object>]      sources
  # @param [Array<Commit>]      commits
  getTagsPlusSources: (targetHashes, cb) ->
    @getTagsFor targetHashes, (er1, tags) =>
      objectHashes = []
      sourceHashes = []
      for tag in tags
        objectHashes.push tag.sha1()
        if tag.sourceSha1
          objectHashes.push tag.sourceSha1
          sourceHashes.push tag.sourceSha1
      @getArguments sourceHashes, (er2, args) =>
        @getPropositions sourceHashes, (er3, props) =>
          sources = []
          for obj in [].concat args, props
            sources.push obj if obj
          @getCommitsFor objectHashes, (er4, commits) =>
            if err = er1 or er2 or er3 or er4
              return cb new @RetrievalError """
                Failed getting tags plus sources from the store."""
            return cb null, tags, sources, commits

  # Add a comment to the store.
  #
  # The comment id is retrieved on success.
  #
  # @param [Comment]            comment
  # @param [Function]           cb(err, id)
  # @param [Error]              err
  # @param [Number]             id
  addComment: (comment, cb) ->
    unless comment instanceof Comment
      return cb new @InputError "Comment instance required to store comment."
    unless comment.validate()
      return cb new @InputError "Comment to store must be valid."

    @store.addComment comment, (err, id) =>
      return cb new @Error "Failed storing comment.", err if err
      return cb null, id

  # Get comments by ids.
  #
  # @param [Array<String>]      ids
  # @param [Function]           cb(err, comments)
  # @param [Error]              err
  # @param [Array<Comment>]     comments
  getComments: (ids, cb) ->
    @store.getComments ids, (err, comments) =>
      if err
        message = "Failed getting comments from the store."
        return cb new @RetrievalError message
      else
        return cb null, comments

  # Add a discussion to the store.
  #
  # The discussion id is retrieved on success.
  #
  # @param [Discussion]         discussion
  # @param [Function]           cb(err, id)
  # @param [Error]              err
  # @param [Number]             id
  addDiscussion: (discussion, cb) ->
    unless discussion instanceof Discussion
      return cb new @InputError "Discussion instance required to store discussion."
    unless discussion.validate()
      return cb new @InputError "Discussion to store must be valid."

    @store.addDiscussion discussion, (err, id) =>
      return cb new @Error "Failed storing discussion.", err if err
      return cb null, id

  # Get discussions by ids.
  #
  # @param [Array<Number>]     ids
  # @param [Function]          cb(err, discussions)
  # @param [Error]             err
  # @param [Array<Discussion>] discussions
  getDiscussions: (ids, cb) ->
    @store.getDiscussions ids, (err, discussions) =>
      if err
        message = "Failed getting discussions from the store."
        return cb new @RetrievalError message
      else
        return cb null, discussions

  # Get discussions for the given target hashes.
  #
  # @param [Array<String>]      targetHashes
  # @param [Function]           cb(err, discussions)
  # @param [Error]              err
  # @param [Array<Discussion>]  discussions
  getDiscussionsFor: (targetHashes, cb) ->
    @store.getDiscussionsFor targetHashes, (err, discussions) =>
      if err
        message = "Failed getting discussions from the store."
        return cb new @RetrievalError message
      else
        return cb null, discussions

  # Search by query for users, arguments and propositions.
  #
  #     storage.search "Chelsea Manning", {}, (err, results) ->
  #       console.log results.arguments unless err
  #
  # @param [String]             query
  # @param [Object]             options
  # @param [Boolean]            options.return_keys
  # @param [Function]           cb(err, results)
  # @param [Object]             results
  # @param [Array<Argument>]    results.arguments
  # @param [Array<Proposition>] results.propositions
  # @param [Array<PublicUser>]  results.users
  search: (query, options, cb) ->
    @store.search query, options, (err, results) =>
      return cb new @RetrievalError "Failed searching store by query." if err
      return cb null, results

module.exports = Storage
