Argumenta   = require '../../lib/argumenta'
Storage     = require '../../lib/argumenta/storage'
User        = require '../../lib/argumenta/user'
PublicUser  = require '../../lib/argumenta/public_user'
Users       = require '../../lib/argumenta/users'
bcrypt      = require 'bcrypt'
should      = require 'should'

describe 'Users', ->

  describe 'new Users( argumenta, storage )', ->
    it 'should create a new users instance', ->
      argumenta = new Argumenta(storageType: 'local')
      users = new Users( argumenta, argumenta.storage )
      users.should.be.an.instanceOf Users
      users.argumenta.should.be.an.instanceOf Argumenta
      users.storage.should.be.an.instanceOf Storage

  describe 'users.create( username, password, email, callback )', ->
    it 'should create a new user account', (done) ->
      argumenta = new Argumenta(storageType: 'local')
      users = new Users( argumenta, argumenta.storage )
      username = 'tester'
      password = 'tester12'
      email = 'tester@xyz.com'
      users.create username, password, email, (err, publicUser) ->
        should.not.exist err
        should.ok publicUser instanceof PublicUser
        should.ok publicUser.validate()
        should.ok publicUser.equals new PublicUser {username, repos: []}

        argumenta.storage.getPasswordHash username, (err, hash) ->
          should.not.exist err
          hash.should.match /\$.+\$.+\$.+/
          should.ok bcrypt.compareSync 'tester12', hash
          done()
