PublicUser = require '../../lib/argumenta/public_user'
fixtures   = require '../../test/fixtures'
should = require 'should'

describe 'PublicUser', ->

  describe 'new PublicUser( username )', ->
    it 'should create a new public user instance', ->
      username = fixtures.validUsername()
      user = new PublicUser username
      user.should.be.an.instanceOf PublicUser
      user.username.should.equal username
      user.validate().should.equal true

  describe 'new PublicUser( params )', ->
    it 'should create a new public user instance', ->
      username = fixtures.validUsername()
      params = username: username
      user1 = new PublicUser params
      user2 = new PublicUser username
      should.ok user1.equals( user2 )

    it 'should not contain private fields', ->
      username = fixtures.validUsername()
      email = fixtures.validEmail()
      hash = fixtures.validPasswordHash()
      user = new PublicUser username: username, email: email, passwordHash: hash
      should.not.exist user.email
      should.not.exist user.passwordHash

  describe 'data()', ->
    it 'should return the user info as a plain object', ->
      user = fixtures.validPublicUser()
      data = user.data()
      data.should.eql {
        username: user.username
      }

  describe 'equals( user )', ->
    it 'should return true for an identical user', ->
      userA = fixtures.validPublicUser()
      userB = new PublicUser( userA.username )
      userA.equals( userB ).should.equal true

    it 'should return false for a different user', ->
      userA = fixtures.uniquePublicUser()
      userB = fixtures.uniquePublicUser()
      userA.equals( userB ).should.equal false

  describe 'validate()', ->
    it 'should return true if the user is valid', ->
      username = fixtures.validUsername()
      user = new PublicUser {username}
      user.validate().should.equal true

    it 'should return false if the username is invalid', ->
      user = new PublicUser {username: ''}
      user.validate().should.equal false
