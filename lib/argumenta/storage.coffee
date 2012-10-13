Base        = require '../argumenta/base'
User        = require '../argumenta/user'
Argument    = require '../argumenta/objects/argument'
Proposition = require '../argumenta/objects/proposition'
Commit      = require '../argumenta/objects/commit'
Tag         = require '../argumenta/objects/tag'

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
  # Create a mongo-backed storage instance:
  #
  #     storage = new Storage
  #       storageType: 'mongo',
  #       storageUrl: 'mongodb://localhost:27017'
  #
  # @param [Object] opts The storage backing options.
  # @param [String] opts.storageType The backing type: 'local' or 'mongo'.
  # @param [String] opts.storageUrl  The backing url, if needed.
  constructor: (opts={}) ->
    {storageType} = opts

    LocalStore = require './storage/local_store'

    switch storageType
      when 'local'
        @store = new LocalStore()
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

  # Instance Methods
  # ----------------

  # Add a user to the store.
  #
  # @param [User] user A valid user with a unique username.
  # @param [Function] cb(err) Called on completion or error.
  # @param [StorageError|ValidationError|StorageConflictError] err Any error.
  addUser: (user, cb) ->
    unless user instanceof User
      return cb new @Error "User instance required to add user."

    unless user.validate()
      return cb user.validationError

    @store.addUser user, (err) ->
      return cb err if err
      return cb null

  # Delete *all* entities from the store.
  #
  # @param [Function]     cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  clearAll: (cb) ->
    @store.clearAll (err) ->
      return cb err

  # Get a user by username, omitting sensitive fields.
  #
  # @see getPasswordHash()
  # @param [String]       username Of the user to retrieve.
  # @param [Function]     cb(err, user) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Object]       user The retrieved user's public fields.
  getUser: (username, cb) ->
    @store.getUser username, (err, user) ->
      return cb new @Error("Failed getting user: " + username, err) if err
      return cb null, user

  # Get a user's password hash.
  #
  # @param [String]       username Of the user whose hash to retrieve.
  # @param [Function]     cb(err, hash) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [String]       hash The retrieved password hash.
  getPasswordHash: (username, cb) ->
    @store.getPasswordHash username, (err, hash) ->
      return cb new @Error("Failed getting user: "  + username, err) if err
      return cb null, hash

  # Get an array of all users, omitting sensitive fields.
  #
  # @param [Function]      cb(err, users) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Object>] users An object array of users' public fields.
  getAllUsers: (cb) ->
    @store.getAllUsers (err, users) ->
      return cb new @Error "Failed getting all users from store." if err
      return cb null, users

  #### Repos ####

  # Add a user repo for a given commit hash.
  #
  # @param [String] username The user's name.
  # @param [String] reponame The repo's name.
  # @param [Function] callback Called on success or error.
  # @param [Error] err Any error.
  # @param [String] commitHash The commit's hash.
  addRepo: (username, reponame, commitHash, callback) ->
    @getUser username, (err, user) =>
      if err or not user
        return callback new @NotFoundError "User required to create repo. Got: #{user}"
      @store.addRepo username, reponame, commitHash, (err) ->
        return callback err

  # Get the commit hash for a given user repo.
  #
  #     storage.getRepoHash username, repo, (err, hash) ->
  #       console.log "This repo points to commit: #{hash}!"
  #
  # @param [String] username The user's name.
  # @param [String] reponame The repo's name.
  # @param [Function] callback Called on success or error.
  # @param [Error] err Any error.
  # @param [String] commitHash This repo's commit hash.
  getRepoHash: (username, reponame, callback) ->
    @store.getRepoHash username, reponame, (err, hash) ->
      return callback null, hash

  # Get the commit and target for a given user repo.
  #
  #     storage.getRepoTarget name, repo, (err, commit, target) ->
  #       console.log "This repo points to commit: #{commit.sha1()}\n"
  #                   "with target: #{target.sha1()}"
  #
  # @param [String] username The user's name.
  # @param [String] reponame The repo's name.
  # @param [Function] cb(err, commit, target) Called on success or error.
  # @param [Error] err Any error.
  # @param [Commit] commit The target commit.
  # @param [Argument] target The target object.
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
  # @param [Array<Array<String>>] keys An array of [username, reponame] arrays.
  # @param [Function] cb(err, repos) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Array<Repo>] repos The retrieved repos.
  getRepos: (keys, cb) ->
    @store.getRepos keys, (err, repos) ->
      return cb err if err
      return cb null, repos

  #### Objects ####

  # Add an argument to the store.
  #
  # @param [Argument] argument The argument to store.
  # @param [Function] cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  addArgument: (argument, cb) ->
    unless argument instanceof Argument
      return cb new @InputError "Argument instance required to store argument."
    unless argument.validate()
      return cb new @InputError "Argument to store must be valid."

    @store.addArgument argument, cb

  # Get an argument from the store by hash.
  #
  # @param [String] hash Hash id of the argument to retrieve.
  # @param [Function] cb(err, args) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Argument] arg The retrieved argument.
  getArgument: (hash, cb) ->
    @store.getArguments [hash], (err, args) =>
      return cb new @RetrievalError "Failed getting arguments from the store." if err
      return cb new @NotFoundError "Argument '#{hash}' not found." unless args.length > 0
      return cb null, args[0]

  # Get arguments from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the arguments to retrieve.
  # @param [Function]      cb(err, args) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Argument>] args The retrieved arguments.
  getArguments: (hashes, cb) ->
    @store.getArguments hashes, (err, args) =>
      return cb new @RetrievalError "Failed getting arguments from the store." if err
      return cb null, args

  # Add an array of propositions to the store.
  #
  # @param [Array<Proposition>] propositions The propositions array.
  # @param [Function]     cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
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
  # @param [String] hash Hash id of the proposition to retrieve.
  # @param [Function] cb(err, proposition) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Proposition] proposition The retrieved proposition.
  getProposition: (hash, cb) ->
    @store.getPropositions [hash], (err, propositions) =>
      return cb new @RetrievalError "Failed getting proposition from the store." if err
      return cb new @NotFoundError "Proposition '#{hash}' not found." unless propositions.length > 0
      return cb null, propositions[0]

  # Get propositions from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the propositions to retrieve.
  # @param [Function]      cb(err, propositions) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Proposition>] propositions The retrieved propositions.
  getPropositions: (hashes, cb) ->
    @store.getPropositions hashes, (err, propositions) ->
      return cb new @Error "Failed getting propositions from the store." if err
      return cb null, propositions

  # Get propositions metadata from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the propositions to retrieve.
  # @param [Function]      cb(err, propositions) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Object>] metadata The retrieved metadata.
  getPropositionsMetadata: (hashes, cb) ->
    @store.getPropositionsMetadata hashes, (err, metadata) ->
      return cb new @Error "Failed getting propositions metadata from the store." if err
      return cb null, metadata

  # Get propositions (along with metadata) from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the propositions to retrieve.
  # @param [Function]      cb(err, propositions) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Proposition>] propositions The retrieved propositions (with metadata).
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
  # @param [Commit] commit The commit to store.
  # @param [Function] cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  addCommit: (commit, cb) ->
    unless commit instanceof Commit
      return cb new @InputError "Commit instance required to store commit."
    unless commit.validate()
      return cb new @InputError "Commit to store must be valid."

    @store.addCommit commit, cb

  # Get a commit from the store by hash.
  #
  # @param [String] hash Hash id of the commit to retrieve.
  # @param [Function] cb(err, commit) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Commit] commit The retrieved commit.
  getCommit: (hash, cb) ->
    @store.getCommits [hash], (err, commits) =>
      return cb new @RetrievalError "Failed getting commit from the store." if err
      return cb new @NotFoundError "Commit '#{hash}' not found." unless commits.length > 0
      return cb null, commits[0]

  # Get commits from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the commits to retrieve.
  # @param [Function]      cb(err, commits) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Commit>] commits The retrieved commits.
  getCommits: (hashes, cb) ->
    @store.getCommits hashes, (err, commits) ->
      return cb new @RetrievalError "Failed getting commits from the store." if err
      return cb null, commits

  # Get commits from the store with given target hashes.
  #
  # @param [Array<String>]  targetHashes Target hashes of tags to retrieve.
  # @param [Function]       cb(err, commits) Called on completion or error.
  # @param [StorageError]   err Any error.
  # @param [Array<Commits>] commits The retrieved commits.
  getCommitsFor: (targetHashes, cb) ->
    @store.getCommitsFor targetHashes, (err, commits) ->
      return cb new @RetrievalError "Failed getting commits from the store." if err
      return cb null, commits

  # Add a tag to the store.
  #
  # @param [Tag] tag The tag to store.
  # @param [Function] cb(err) Called on completion or error.
  # @param [StorageError] err Any error.
  addTag: (tag, cb) ->
    unless tag instanceof Tag
      return cb new @InputError "Tag instance required to store tag."
    unless tag.validate()
      return cb new @InputError "Tag to store must be valid."

    @store.addTag tag, cb

  # Get a tag from the store by hash.
  #
  # @param [String] hash Hash id of the tag to retrieve.
  # @param [Function] cb(err, tag) Called on completion or error.
  # @param [StorageError] err Any error.
  # @param [Tag] tag The retrieved tag.
  getTag: (hash, cb) ->
    @store.getTags [hash], (err, tags) =>
      return cb new @RetrievalError "Failed getting tag from the store." if err
      return cb new @NotFoundError "Tag '#{hash}' not found." unless tags.length > 0
      return cb null, tags[0]

  # Get tags from the store by hashes.
  #
  # @param [Array<String>] hashes Hash ids of the tags to retrieve.
  # @param [Function]      cb(err, tags) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Tag>] tags The retrieved tags.
  getTags: (hashes, cb) ->
    @store.getTags hashes, (err, tags) ->
      return cb new @RetrievalError "Failed getting tags from the store." if err
      return cb null, tags

  # Get tags from the store with given target hashes.
  #
  # @param [Array<String>] targetHashes Target hashes of tags to retrieve.
  # @param [Function]      cb(err, tags) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Tag>]    tags The retrieved tags.
  getTagsFor: (targetHashes, cb) ->
    @store.getTagsFor targetHashes, (err, tags) ->
      return cb new @RetrievalError "Failed getting tags from the store." if err
      return cb null, tags

  # Get tags (plus any source objects) from the store given target hashes.
  #
  # @param [Array<String>] targetHashes Target hashes of tags to retrieve.
  # @param [Function]      cb(err, tags) Called on completion or error.
  # @param [StorageError]  err Any error.
  # @param [Array<Tag>]    tags The tags for the given targets.
  # @param [Array<Object>] sources Any source objects for the tags.
  # @param [Array<Commit>] commits The commits for tags and sources.
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

module.exports = Storage
