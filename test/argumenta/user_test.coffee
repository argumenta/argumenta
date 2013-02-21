User     = require '../../lib/argumenta/user'
fixtures = require '../../test/fixtures'
bcrypt = require 'bcrypt'
should = require 'should'

describe 'User', ->

  describe 'new User( username, email, passwordHash )', ->
    it 'should create a new user instance', ->
      username = fixtures.validUsername()
      email = fixtures.validEmail()
      hash = fixtures.validPasswordHash()

      user = new User username, email, hash

      user.should.be.an.instanceOf User
      user.username.should.equal username
      user.email.should.equal email
      user.passwordHash.should.equal hash
      user.validate().should.equal true

  describe 'new User( params )', ->
    it 'should create a new user instance', ->
      username = fixtures.validUsername()
      email = fixtures.validEmail()
      hash = fixtures.validPasswordHash()
      params = username: username, email: email, passwordHash: hash
      user1 = new User params
      user2 = new User username, email, hash
      should.ok user1.equals( user2 )

  describe 'User.validatePassword()', ->
    validatorFor = (pass) ->
      return -> User.validatePassword( pass )

    it 'should return true if password is 6 characters or more', ->
      validatorFor('123456').should.not.throw
      should.ok User.validatePassword( '123456' )

    it 'should throw if password is less than 6 characters', ->
      validatorFor('12345').should.throw

  describe 'equals( user )', ->
    it 'should return true for an identical user', ->
      userA = fixtures.validUser()
      userB = fixtures.validUser()
      userA.equals( userB ).should.equal true

    it 'should return false for a different user', ->
      userA = fixtures.uniqueUser()
      userB = fixtures.uniqueUser()
      userA.equals( userB ).should.equal false

  describe 'validate()', ->
    username      = fixtures.validUsername()
    passwordHash  = fixtures.validPasswordHash()
    email         = fixtures.validEmail()

    it 'should return true if the user is valid', ->
      user = new User {username, passwordHash, email}
      user.validate().should.equal true

    it 'should return false if the username is missing', ->
      user = new User {passwordHash, email}
      user.validate().should.equal false

    it 'should return false if the username is blank', ->
      user = new User {username: '', passwordHash, email}
      user.validate().should.equal false

    it 'should return false if the passwordHash is missing', ->
      user = new User {username, email}
      user.validate().should.equal false

    it 'should return false if the email is invalid', ->
      user = new User {username, passwordHash, email: 'bad-email'}
      user.validate().should.equal false
