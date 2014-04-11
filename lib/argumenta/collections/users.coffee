Base = require '../../argumenta/base'
Auth = require '../../argumenta/auth'
User = require '../../argumenta/user'
PublicUser = require '../../argumenta/public_user'

#
# Users models user accounts.  
# It integrates the Storage, Auth, and User modules.
#
class Users extends Base

  ### Errors ###

  Error: @Error = @Errors.Users

  ### Constructor ###

  # Inits a Users instance.
  #
  # @api public
  # @param [Argumenta] argumenta An argumenta instance.
  # @param [Storage]   storage A storage instance.
  constructor: (@argumenta, @storage) ->

  ### Instance Methods ###

  # Creates a user account for the given `options`.
  #
  #     users.create options, (err, user) ->
  #       console.log "created account for #{user.username}!" unless err
  #
  # @api public
  # @param [Object]     options
  # @param [String]     options.username
  # @param [String]     options.password
  # @param [String]     options.email
  # @param [Date]       options.join_date
  # @param [String]     options.join_ip
  # @param [Function]   callback(err, user)
  # @param [Error]      err
  # @param [PublicUser] publicUser
  create: (options, callback) ->
    {username, password} = options

    try User.validatePassword password
    catch err
      return callback err, null

    Auth.hashPassword password, (err, hash) =>
      return callback err, null if err

      user = new User {
        username:      username
        password_hash: hash
        email:         options.email
        join_date:     options.join_date
        join_ip:       options.join_ip
      }

      @storage.addUser user, (err) =>
        return callback err, null if err

        @storage.getUser username, (err, publicUser) =>
          return callback err, null if err
          return callback null, publicUser

  # Gets a user resource by username, with metadata and latest repos.
  #
  # @api public
  # @param [String]     username
  # @param [Function]   callback(err, user)
  # @param [Error]      err
  # @param [PublicUser] user
  get: (username, callback) ->

    @storage.getUsersWithMetadata [username], (err, users) =>
      return callback err if err
      return callback new @Error "User not found." unless users.length > 0

      user = users[0]
      repoOpts = { offset: 0, limit: 50, latest: true }
      @storage.getUserRepos username, repoOpts, (err, repos) =>
        return callback err if err
        user.repos = repos

        return callback null, user

  # Gets latest users.
  #
  # @api public
  # @param [Object]            options
  # @param [Number]            options.limit
  # @param [Number]            options.offset
  # @param [Function]          callback(err, users)
  # @param [Error]             err
  # @param [Array<PublicUser>] users
  latest: (options, callback) ->

    @storage.store.listUsers options, (err, usernames) =>
      return callback new @Error "Latest usernames not found." if err
      return callback null, [] if usernames.length is 0

      @storage.getUsersWithMetadata usernames, (err, users) =>
        return callback new @Error "Latest users not found." if err
        return callback null, users

module.exports = Users
