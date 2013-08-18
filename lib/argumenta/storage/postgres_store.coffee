async        = require 'async'
pg           = require 'pg'
Transaction  = require 'pg-nest'
_            = require 'underscore'
Base         = require '../../argumenta/base'
Objects      = require '../../argumenta/objects'
PublicUser   = require '../../argumenta/public_user'
Repo         = require '../../argumenta/repo'
Queries      = require './queries'
Session      = null

{Argument, Proposition, Commit, Tag} = Objects

#
# PostgresStore provides a datastore backed by PostgresSQL.  
# Designed for use with the Storage module.
#
class PostgresStore extends Base

  # Prototype and static refs to custom error class.
  Error: @Error = @Errors.PostgresStore

  # Inits a PostgresStore instance for the given connection URL.
  #
  #     connectionUrl = 'pg://user:pass@localhost:5432/argumenta'
  #     store = new PostgresStore connectionUrl
  #
  # @api public
  constructor: (@connectionUrl, @sessionClient) ->
    Session ?= require './postgres_session'
    @pg = pg

  # Retrieves a pg client from the connection pool (or session) asynchronously.
  #
  #     store.client (err, client) ->
  #       query = 'SELECT * FROM Objects WHERE sha1 = $1'
  #       client.query query, [sha1], (err, result) ->
  #         console.log result.rows[0]
  #
  # @api private
  # @see pg.Client
  client: (callback) ->
    if @sessionClient
      return callback null, @sessionClient

    @pg.connect @connectionUrl, (err, client) =>
      callback err, client

  # Creates a session with a new or nested transaction.
  #
  # Any method of PostgresStore or Transaction may be called on the session:
  #
  #     store.session (er1, session) ->
  #       session.addUser user, (er2) ->
  #         session.addArgument arg, (er3) ->
  #           session.finalize (er1 or er2 or er3), (err) ->
  #             console.log "Done!" unless err
  #
  # @api private
  # @see PostgresSession, pg-nest
  session: (callback) ->
    @client (err, client) =>
      return callback err if err

      transaction = new Transaction client, @transaction
      transaction.start (err) =>
        return callback err if err

        session = new Session @connectionUrl, client, transaction
        return callback null, session

  # Syntactic sugar for client.query().
  # @api private
  # @see pg.Client#query
  query: (args..., callback) ->
    @client (err, client) ->
      return callback err if err
      client.query args..., callback

  # Runs queries within a nested transaction, rolling back on any error.
  #
  #     queries = [
  #       "INSERT INTO Foo VALUES ('bar');"
  #       "INSERT INTO Bar VALUES ('baz');"
  #     ]
  #     store.runQueries queries, (err) ->
  #       console.log 'Done!' unless err
  #
  # @api private
  runQueries: (queries, callback) ->
    @session (err, session) ->
      return callback err if err

      doQuery = (q, cb) -> session.query q, cb
      async.forEachSeries queries, doQuery, (err) ->
        session.finalize err, callback

  #### Storage ####

  # Deletes *all* entities from the store.
  # @api public
  clearAll: (opts, callback) ->

    if opts.quick
    then query = Queries.deleteAll()
    else query = Queries.truncateAll()

    @query query, (err, res) ->
      return callback err if err
      return callback null, res

  #### Users ####

  # Adds the given user to the store.
  # @api public
  addUser: (user, callback) ->
    @query Queries.insertUser(user), (err, res) ->
      return callback err if err
      return callback null

  # Gets the *public* properties of all users.
  # @api public
  getAllUsers: (callback) ->
    @query Queries.listUsers(), (err, res) =>
      return callback err if err

      users = []
      users.push new PublicUser( row ) for row in res.rows
      return callback null, users

  # Gets the *public* properties of a user by name.
  # @api public
  getUser: (username, callback) ->
    @query Queries.selectUser(username), (err, res) =>
      return callback err if err
      unless res.rows.length > 0
        return callback new @Errors.NotFound "No user for username: '#{username}'"

      row = res.rows[0]
      publicUser = new PublicUser( row )
      return callback null, publicUser

  # Gets the *public* properties of users by usernames.
  # @api public
  getUsers: (usernames, callback) ->
    @query Queries.selectUsers(usernames), (err, res) =>
      return callback err if err

      publicUsers = []
      publicUsers.push new PublicUser( row ) for row in res.rows
      return callback null, publicUsers

  # Gets a list of repos for the given user.
  # @api public
  getUserRepos: (username, opts, callback) ->
    query = Queries.listUserRepos( username, opts )
    @query query, (err, result) =>
      return callback err if err

      keys = []
      for row in result.rows
        keys.push [row.username, row.reponame]

      @getRepos keys, (err, repos) =>
        return callback err if err
        return callback null, repos

  # Gets a user's password hash.
  # @api public
  getPasswordHash: (username, callback) ->
    query = Queries.selectPasswordHash( username )
    @query query, (err, res) =>
      return callback err if err
      unless res.rows.length > 0
        return callback new @Error "No user for username: '#{username}'"

      row = res.rows[0]
      passwordHash = row.password_hash
      return callback null, passwordHash

  #### Repos ####

  # Add a user repo for a given commit hash.
  # @api public
  addRepo: (username, reponame, commitHash, callback) ->
    @session (err, session) ->
      return callback err if err

      query = Queries.insertRepo(username, reponame, commitHash)
      session.query query, (err) ->
        session.finalize err, callback

  # Delete a repo by owner and name.
  # @api public
  deleteRepo: (username, reponame, callback) ->
    @session (err, session) =>
      return callback err if err

      key = [username, reponame]
      @getRepos [key], (err, repos) ->
        return callback err if err
        return callback null if repos.length == 0

        query = Queries.deleteRepo(username, reponame)
        session.query query, (err) ->
          session.finalize err, callback

  # Get the commit hash for a given user repo.
  # @api public
  getRepoHash: (username, reponame, callback) ->
    query = Queries.selectRepo(username, reponame)
    @query query, (err, result) ->
      return callback err if err

      hash = result.rows[0]?.commit_sha1
      return callback null, hash

  # Get repos for an array of [username, reponame] key pairs.
  # @api public
  getRepos: (keypairs, callback) ->
    query = Queries.selectRepos( keypairs )
    @query query, (err, result) =>
      return callback err if err

      keyFor = (username, reponame) ->
        return username + '/' + reponame

      data = {byKey: {}, byCommit: {}, byTarget: {}}
      argSha1s = []
      for row in result.rows
        row.parent_sha1s = Queries.parseArray row.parent_sha1s
        repoData = {
          username: row.username
          reponame: row.reponame
          user:     new PublicUser( row )
          commit:   new Commit( row )
          target:   null
        }
        data.byKey[keyFor(row.username, row.reponame)] = repoData
        data.byCommit[row.commit_sha1] = repoData
        data.byTarget[row.target_sha1] = repoData
        argSha1s.push row.target_sha1

      @getArguments argSha1s, (err, args) =>
        return callback err if err

        for argument in args
          repoData = data.byTarget[argument.sha1()]
          repoData.target = argument

        repos = []
        for pair in keypairs
          repoData = data.byKey[keyFor(pair[0], pair[1])]
          repo = new Repo( repoData )
          if repo.validate()
            repos.push repo

        return callback null, repos

  #### Commits ####

  # Add a commit to the store.
  # @api public
  addCommit: (commit, callback) ->
    sha1 = commit.sha1()
    @getCommits [sha1], (err, commits) =>
      return callback err if err
      return callback null if commits.length > 0

      @session (err, session) ->
        return callback err if err

        queries = [
          Queries.insertObject(commit)
          Queries.insertCommit(commit)
        ]
        session.runQueries queries, (err) ->
          session.finalize err, callback

  # Get commits from the store by hashes.
  # @api public
  getCommits: (hashes, callback) ->
    query = Queries.selectCommitsBySha1s( hashes )
    @query query, (err, result) ->
      return callback err if err

      data = {}
      for row in result.rows
        row.parent_sha1s = Queries.parseArray(row.parent_sha1s)
        data[row.commit_sha1] = row

      commits = []
      for hash in hashes
        row = data[hash]
        commits.push new Commit( row ) if row

      return callback null, commits

  # Get commits from the store for the given target hashes.
  # @api public
  getCommitsFor: (targetHashes, callback) ->
    query = Queries.selectCommitsByTargetSha1s(targetHashes)
    @query query, (err, result) ->
      return callback err if err

      data = { byTarget: {} }
      for row in result.rows
        row.parent_sha1s = Queries.parseArray(row.parent_sha1s)
        data.byTarget[row.target_sha1] = row

      commits = []
      for hash in targetHashes
        row = data.byTarget[hash]
        commits.push new Commit( row ) if row

      return callback null, commits

  #### Arguments ####

  # Adds an argument to the store.
  # @api public
  addArgument: (argument, callback) ->
    @session (err, session) ->
      return callback err if err

      sha1 = argument.sha1()
      session.getArguments [sha1], (err, args) ->
        return callback err if err
        return callback null if args[0]?

        async.series [
          (cb) -> session.query Queries.insertObject(argument), cb
          (cb) -> session.query Queries.insertArgument(argument), cb
          (cb) -> session.addPropositions argument.propositions, cb
          (cb) ->
            queries = argument.propositions.map (prop, index) ->
              Queries.insertArgumentProposition(argument, prop, index+1)
            session.runQueries queries, cb
        ], (err) ->
          session.finalize err, callback

  # Get arguments from the store by hashes.
  # @api public
  getArguments: (hashes, callback) ->
    query = Queries.selectArgumentsBySha1s(hashes)
    @query query, (err, result) =>
      return callback err if err

      data = {}
      for row in result.rows
        sha1 = row.argument_sha1
        data[sha1] ?= { title: row.title, propositions: [] }
        data[sha1].propositions.push( row.text )

      args = []
      for hash in hashes
        if d = data[hash]
          d.premises = d.propositions
          d.conclusion = d.propositions.pop()
          args.push new Argument( d.title, d.premises, d.conclusion )

      return callback null, args

  #### Propositions ####

  # Add a valid proposition to the store.
  # @api public
  addProposition: (proposition, callback) ->
    @session (err, session) ->
      return callback err if err

      session.getPropositions [proposition.sha1()], (err, props) ->
        return callback err if err
        return callback null if props.length > 0

        queries = [
          Queries.insertObject(proposition)
          Queries.insertProposition(proposition)
        ]
        session.runQueries queries, (err) ->
          session.finalize err, callback

  # Adds each proposition to the store.
  # @api public
  addPropositions: (propositions, callback) ->
    @session (err, session) =>
      return callback err if err

      addProp = (p, cb) ->
        session.addProposition p, (err) ->
          return cb err

      async.forEachSeries propositions, addProp, (err) ->
        session.finalize err, callback

  # Get propositions from the store by hashes.
  # @api public
  getPropositions: (hashes, callback) ->
    query = Queries.selectPropositionsBySha1s(hashes)
    @query query, (err, result) ->
      return callback err if err

      data = {}
      for row in result.rows
        data[row.proposition_sha1] = row

      props = []
      for hash in hashes
        row = data[hash]
        props.push new Proposition( row.text ) if row

      return callback null, props
      return callback null

  # Get propositions metadata by hashes.
  # @api public
  getPropositionsMetadata: (hashes, callback) ->
    query = Queries.selectPropositionsMetadataBySha1s( hashes )
    @query query, (err, result) ->
      return callback err if err

      data = {}
      for hash in hashes
        data[hash] = {
          sha1: hash
          tag_sha1s: { support: [], dispute: [], citation: [] }
          tag_counts: { support: 0, dispute: 0, citation: 0 }
        }

      for row in result.rows
        sha1 = row.proposition_sha1
        tag_type = row.tag_type
        tag_sha1 = row.tag_sha1
        data[sha1].tag_sha1s[tag_type].push tag_sha1
        data[sha1].tag_counts[tag_type]++

      metadata = []
      metadata.push data[key] for key of data

      return callback null, metadata

  #### Tags ####

  # Add a tag to the store.
  # @api public
  addTag: (tag, callback) ->
    @session (err, session) ->
      return callback err if err

      session.getTags [tag.sha1()], (err, tags) ->
        return callback err if err
        return callback null if tags[0]?

        queries = [
          Queries.insertObject(tag)
          Queries.insertTag(tag)
        ]
        session.runQueries queries, (err) ->
          session.finalize err, callback

  # Get tags from the store by hashes.
  # @api public
  getTags: (hashes, callback) ->
    query = Queries.selectTagsBySha1s hashes
    @query query, (err, result) ->
      return callback err if err

      tags = []
      for row in result.rows
        tags.push new Tag( row )

      return callback null, tags

  # Get tags from the store with the given target hashes.
  # @api public
  getTagsFor: (targetHashes, callback) ->
    query = Queries.selectTagsByTargetSha1s targetHashes
    @query query, (err, result) ->
      return callback err if err

      tags = []
      for row in result.rows
        tags.push new Tag( row )

      return callback null, tags

  #### Search ####

  # Search by query for arguments.
  # @api private
  searchArguments: (query, options, callback) ->
    argQuery = Queries.searchArguments query, options
    @query argQuery, (err, res) =>
      return callback err if err

      argHashes = []
      argHashes.push row.argument_sha1 for row in res.rows
      @getArguments argHashes, (err, args) =>
        return callback err if err
        return callback null, args

  # Search by query for users.
  # @api private
  searchUsers: (query, options, callback) ->
    userQuery = Queries.searchUsers query, options
    @query userQuery, (err, res) =>
      return callback err if err

      usernames = []
      usernames.push row.username for row in res.rows
      @getUsers usernames, (err, users) =>
        return callback err if err
        return callback null, users

  # Search by query for users, arguments, propositions, and tags.
  # @api public
  search: (query, options, callback) ->
    @searchArguments query, options, (er1, args) =>
      @searchUsers query, options, (er2, users) =>
        err = er1 or er2
        return callback err if err

        results =
          arguments : args
          users     : users

        return callback null, results

module.exports = PostgresStore
