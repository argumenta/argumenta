config      = require '../../config'
Argumenta   = require '../../lib/argumenta'
Storage     = require '../../lib/argumenta/storage'
User        = require '../../lib/argumenta/user'
PublicUser  = require '../../lib/argumenta/public_user'
Users       = require '../../lib/argumenta/users'
fixtures    = require '../../test/fixtures'
bcrypt      = require 'bcrypt'
should      = require 'should'

describe 'Users', ->

  options =
    storageType: 'postgres'
    storageUrl:  config.postgresUrl
    host: 'testing.argumenta.io'

  argumenta = new Argumenta options

  beforeEach (done) ->
    argumenta.storage.clearAll {quick: true}, (err) ->
      should.not.exist err
      done()

  after (done) ->
    argumenta.storage.clearAll {}, (err) ->
      should.not.exist err
      done()

  withUser = (callback) ->
    {username} = data = fixtures.uniqueUserData()
    arg = fixtures.uniqueArgument()
    argumenta.users.create data, (err, user) ->
      should.not.exist err
      return callback user

  withArgument = (callback) ->
    {username} = data = fixtures.uniqueUserData()
    arg = fixtures.uniqueArgument()
    argumenta.users.create data, (er1, user) ->
      argumenta.arguments.commit username, arg, (er2, commit) ->
        argumenta.storage.getArgument arg.sha1(), (er3, argument) ->
          [er1, er2, er3].should.eql [1..3].map -> null
          return callback user, commit, argument

  describe 'new Users( argumenta, storage )', ->
    it 'should create a new users instance', ->
      users = new Users( argumenta, argumenta.storage )
      users.should.be.an.instanceOf Users
      users.argumenta.should.be.an.instanceOf Argumenta
      users.storage.should.be.an.instanceOf Storage

  describe 'users.create( options, callback )', ->
    it 'should create a new user account', (done) ->
      {username} = data = fixtures.validUserData()
      argumenta.users.create data, (err, publicUser) ->
        should.not.exist err
        should.ok publicUser instanceof PublicUser
        should.ok publicUser.validate()
        should.ok publicUser.equals new PublicUser {username, repos: []}

        argumenta.storage.getPasswordHash username, (err, hash) ->
          should.not.exist err
          hash.should.match /\$.+\$.+\$.+/
          should.ok bcrypt.compareSync 'tester12', hash
          done()

  describe 'users.get( username, callback )', ->
    it 'should get a user resource by username', (done) ->
      withUser (user) ->
        username = user.username
        argumenta.users.get username, (err, retrievedUser) ->
          should.not.exist err
          should.ok retrievedUser.equals user
          done()
