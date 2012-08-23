Argumenta = require '../../lib/argumenta'
Storage   = require '../../lib/argumenta/storage'
User      = require '../../lib/argumenta/user'
Users     = require '../../lib/argumenta/users'
bcrypt    = require 'bcrypt'
should    = require 'should'

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
      users.create username, password, email, (err, user) ->
        should.not.exist err
        user.should.be.an.instanceOf User
        user.validate().should.equal true

        # Test values
        should.not.exist user.password
        user.username.should.equal      'tester'
        user.email.should.equal         'tester@xyz.com'
        user.password_hash.should.match /\$.+\$.+\$.+/

        # Verify password
        should.ok bcrypt.compareSync 'tester12', user.password_hash
        done()
