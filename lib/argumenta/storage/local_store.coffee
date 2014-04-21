_           = require 'underscore'
Base        = require '../../argumenta/base'
Comment     = require '../../argumenta/comment'
Discussion  = require '../../argumenta/discussion'
Argument    = require '../../argumenta/objects/argument'
Proposition = require '../../argumenta/objects/proposition'
ObjectUtils = require '../../argumenta/objects/object_utils'
PublicUser  = require '../../argumenta/public_user'
Repo        = require '../../argumenta/repo'

class LocalStore extends Base

  # Prototype and static refs to custom error class.
  Error: @Error = @Errors.LocalStore

  constructor: () ->
    @initHashes()

  # Inits all hashes for the store.
  initHashes: () ->
    # Users and repos
    @users = {}
    @repos = {}

    # Objects
    @arguments = { bySha1: {} }
    @propositions = { bySha1: {} }
    @commits = { bySha1: {}, withTargetSha1: {} }
    @tags = { bySha1: {}, withTargetSha1: {} }

    # Comments and discussions
    @discussions = { byId: [], withTargetSha1: {} }
    @comments = { byId: [], withDiscussionId: {} }

  # Delete *all* entities from the store.
  clearAll: (opts, cb) ->
    @initHashes()
    return cb null

  # Store a User in memory.
  addUser: (user, cb) ->
    # Check for existing user
    if @users[user.username]
      return cb new @Errors.StorageConflict 'User already exists.'

    # Store the user
    @users[user.username] = user

    # Success
    return cb null

  # Gets the *public* properties of a user by name.
  getUser: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    publicUser = new PublicUser(
      username:     u.username
      join_date:    u.joinDate
      gravatar_id:  ObjectUtils.MD5(u.email.toLowerCase())
    )

    return cb null, publicUser

  # Gets the *public* properties of users by usernames.
  getUsers: (usernames, cb) ->
    users = []
    for username in usernames
      u = @users[username]

      publicUser = new PublicUser(
        username:     u.username
        join_date:    u.joinDate
        gravatar_id:  ObjectUtils.MD5(u.email.toLowerCase())
      )

      users.push publicUser

    return cb null, users

  # Gets public metadata for users by usernames.
  getUsersMetadata: (usernames, cb) ->
    metadata = []
    for name in usernames
      data =
        username    : name
        repos_count : 0
      for reponame, hash of @repos[name]
        data.repos_count++
      metadata.push data
    return cb null, metadata

  # Gets a user's password hash.
  getPasswordHash: (username, cb) ->
    u = @users[username]
    unless u
      return cb new @Error("No user for username: " + username), null

    return cb null, u.passwordHash

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
    @repos[username] ?= {}
    @repos[username][reponame] = commitHash

    return callback null

  # Delete a repo by owner and name.
  deleteRepo: (username, reponame, callback) ->
    key = [username, reponame]
    @getRepos [key], (err, repos) =>
      return callback err if err
      return callback null if repos.length == 0

      delete @repos[username][reponame]
      return callback null

  # Get the commit hash for a given user repo.
  getRepoHash: (username, reponame, callback) ->
    hash = @repos[username]?[reponame]
    return callback null, hash

  # Get repos for an array of [username, reponame] key pairs.
  getRepos: (keys, callback) ->
    repos = []
    for key in keys
      [username, reponame] = key

      u = @users[username]
      user = new PublicUser(
        username:     u.username
        join_date:    u.joinDate
        gravatar_id:  ObjectUtils.MD5(u.email.toLowerCase())
      )
      commit = @commits.bySha1[ @repos[username]?[reponame] ]
      target = @arguments.bySha1[ commit?.targetSha1 ]
      repo = new Repo( user, reponame, commit, target )

      if repo.validate()
        repos.push repo

    return callback null, repos

  # List key pairs for latest repos.
  listRepos: (options, callback) ->
    limit  = options.limit  ? 50
    offset = options.offset ? 0
    latest = options.latest ? true

    commits = _(@commits.bySha1)
      .chain()
      .values()
      .where(targetType: 'argument')

    commits = commits.reverse() unless latest
    commits = commits.slice(offset, offset + limit).value()

    keys = []
    for c in commits
      username = c.committer
      argument = @arguments.bySha1[c.targetSha1]
      reponame = argument.repo()
      keys.push [username, reponame]

    return callback null, keys

  #### Objects ####

  # Add an argument to the store
  addArgument: (argument, cb) ->
    hash = argument.sha1()
    @arguments.bySha1[ hash ] = argument

    argument.metadata =
      discussions_count: 0

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
      results.push new Proposition p.text if p?

    return cb null, results

  # Get propositions metadata by hashes.
  getPropositionsMetadata: (hashes, cb) ->
    results = []
    for hash in hashes
      tags = @tags.withTargetSha1[hash] or []
      metadata = {
        sha1: hash
        object_type: 'proposition'
        tag_sha1s: {
          support: []
          dispute: []
          citation: []
        }
        tag_counts: {
          support: 0
          dispute: 0
          citation: 0
        }
      }
      sha1s = metadata.tag_sha1s
      counts = metadata.tag_counts
      sha1s[tag.tagType].push tag.sha1() for tag in tags
      counts[type] = sha1s[type].length for type in Object.keys counts
      results.push metadata

    return cb null, results

  # Add an commit to the store
  addCommit: (commit, cb) ->
    hash = commit.sha1()
    @commits.bySha1[ hash ] = commit
    @commits.withTargetSha1[ commit.targetSha1 ] ?= []
    @commits.withTargetSha1[ commit.targetSha1 ].push commit

    return cb null

  # Get commits from the store by hashes.
  getCommits: (hashes, cb) ->
    results = []
    for hash in hashes
      c = @commits.bySha1[hash]
      results.push c if c?

    return cb null, results

  # Get commits from the store with given target hashes.
  getCommitsFor: (targetHashes, options..., cb) ->
    options = options[0] ? {}
    committer = options.committer

    results = []
    for hash in targetHashes
      commits = @commits.withTargetSha1[hash]
      results = results.concat commits or []

    if committer
      results = _(results)
        .where(committer: committer)

    return cb null, results

  # Add a tag to the store
  addTag: (tag, cb) ->
    hash = tag.sha1()
    @tags.bySha1[ hash ] = tag
    @tags.withTargetSha1[ tag.targetSha1 ] ?= []
    @tags.withTargetSha1[ tag.targetSha1 ].push tag

    return cb null

  # Get tags from the store by hashes.
  getTags: (hashes, cb) ->
    results = []
    for hash in hashes
      t = @tags.bySha1[hash]
      results.push t if t?

    return cb null, results

  # Get tags from the store with given target hashes.
  getTagsFor: (targetHashes, cb) ->
    results = []
    for hash in targetHashes
      tags = @tags.withTargetSha1[hash]
      results = results.concat tags or []

    return cb null, results

  #### Comments ####

  # Add a comment to the store.
  addComment: (comment, cb) ->
    @getUser comment.author, (err, publicUser) =>
      return cb err if err

      id = @comments.byId.length
      @comments.byId[id] = comment
      comment.commentId = id
      comment.gravatarId = publicUser.gravatarId

      discussionId = comment.discussionId
      @comments.withDiscussionId[discussionId] or= []
      @comments.withDiscussionId[discussionId].push comment

      return cb null, id

  # Get comments by ids.
  getComments: (ids, cb) ->
    comments = []
    for id in ids
      comments.push @comments.byId[id]

    return cb null, comments

  #### Discussions ####

  # Add a discussion to the store.
  addDiscussion: (discussion, cb) ->
    id = @discussions.byId.length
    @discussions.byId[id] = discussion
    discussion.discussionId = id
    discussion.targetOwner =
      @commits.withTargetSha1[discussion.targetSha1][0].committer

    hash = discussion.targetSha1
    @discussions.withTargetSha1[hash] or= []
    @discussions.withTargetSha1[hash].push discussion

    if discussion.targetType is 'argument'
      argument = @arguments.bySha1[discussion.targetSha1]
      metadata = argument.metadata ?= {}
      metadata.discussions_count = @discussions.withTargetSha1[hash].length

    return cb null, id

  # Get discussions by ids.
  getDiscussions: (ids, cb) ->
    discussions = []
    for id in ids
      discussions.push @discussions.byId[id]

    return cb null, discussions

  # Get discussions for given target hashes.
  getDiscussionsFor: (targetHashes, cb) ->
    discussions = []
    for hash in targetHashes
      continue unless @discussions.withTargetSha1[hash]
      for d in @discussions.withTargetSha1[hash]
        discussions.push d if d

    return cb null, discussions

  # Search by query for users, arguments, propositions, and tags.
  search: (query, options, cb) ->
    regex = new RegExp query, 'i'
    args = []
    for k, a of @arguments.bySha1
      fullText = a.title
      fullText += ' ' + p.text for p in a.propositions
      if fullText.match regex
        if options.return_keys
        then args.push a.sha1()
        else args.push new Argument a.data()

    users = []
    for k, u of @users
      if u.username.match regex
        if options.return_keys
        then users.push u.username
        else users.push new PublicUser u

    props = []
    for k, p of @propositions.bySha1
      if p.text.match regex
        if options.return_keys
        then props.push p.sha1()
        else props.push new Proposition p.text

    results =
      arguments:    args
      propositions: props
      users:        users

    return cb null, results

module.exports = LocalStore
