Base       = require '../../argumenta/base'
PublicUser = require '../../argumenta/public_user'

class LocalStore extends Base

  # Prototype and static refs to custom error class.
  Error: @Error = @Errors.LocalStore

  constructor: () ->
    # Init users hash
    @users = {}

    # Init object hashes
    @arguments = { bySha1: {} }
    @propositions = { bySha1: {} }
    @commits = { bySha1: {} }
    @tags = { bySha1: {} }

  # Store a User in memory.
  addUser: (user, cb) ->
    # Check for existing user
    if @users[user.username]
      return cb new @Errors.StorageConflict 'User already exists.'

    # Store the user
    @users[user.username] = user

    # Success
    return cb null

  # Delete *all* entities from the store.
  clearAll: (cb) ->
    @users = {}
    for collection in [@arguments, @propositions, @commits, @tags]
      collection.bySha1 = {}

    return cb null

  # Gets the *public* properties of a user by name.
  getUser: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    publicUser = new PublicUser
      username: u.username,
      repos:    u.repos

    return cb null, publicUser

  getPasswordHash: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    return cb null, u.password_hash

  # Gets the *public* properties of all users.
  getAllUsers: (cb) ->

    publicUsers = []

    for name, u of @users
      publicUser = {username: u.username}
      publicUsers.push publicUser

    # Success
    return cb null, publicUsers

  #### Repos ####

  # Add a user repo for a given commit hash.
  addRepo: (username, reponame, commitHash, callback) ->
    @users[username].repos ?= {}
    @users[username].repos[reponame] = commitHash
    return callback null

  # Get the commit hash for a given user repo.
  getRepoHash: (username, reponame, callback) ->
    hash = @users[username].repos?[reponame]
    return callback null, hash

  # Get repos for an array of [username, reponame] key pairs.
  getRepos: (keys, callback) ->
    repos = []
    for key in keys
      [username, reponame] = key

      user = new PublicUser @users[username]
      commit = @commits.bySha1[ user.repos?[reponame] ]
      target = @arguments.bySha1[ commit?.targetSha1 ]

      repos.push repo = {
        username: username
        reponame: reponame
        user: user
        commit: commit
        target: target
      }
    return callback null, repos

  #### Objects ####

  # Add an argument to the store
  addArgument: (argument, cb) ->
    hash = argument.sha1()
    @arguments.bySha1[ hash ] = argument

    @addPropositions argument.propositions, (err) ->
      return cb err if err
      return cb null

  # Get arguments from the store by hashes.
  getArguments: (hashes, cb) ->
    results = []
    for hash in hashes
      a = @arguments.bySha1[hash]
      results.push a if a?

    return cb null, results

  # Add an array of valid propositions to the store.
  addPropositions: (propositions, cb) ->
    for p in propositions
      hash = p.sha1()
      if not @propositions.bySha1[hash]
        @propositions.bySha1[hash] = p

    return cb null

  # Get propositions from the store by hashes.
  getPropositions: (hashes, cb) ->
    results = []
    for hash in hashes
      p = @propositions.bySha1[hash]
      results.push p if p?

    return cb null, results

  # Add an commit to the store
  addCommit: (commit, cb) ->
    hash = commit.sha1()
    @commits.bySha1[ hash ] = commit

    return cb null

  # Get commits from the store by hashes.
  getCommits: (hashes, cb) ->
    results = []
    for hash in hashes
      c = @commits.bySha1[hash]
      results.push c if c?

    return cb null, results

  # Add a tag to the store
  addTag: (tag, cb) ->
    hash = tag.sha1()
    @tags.bySha1[ hash ] = tag

    return cb null

  # Get tags from the store by hashes.
  getTags: (hashes, cb) ->
    results = []
    for hash in hashes
      t = @tags.bySha1[hash]
      results.push t if t?

    return cb null, results

module.exports = LocalStore
