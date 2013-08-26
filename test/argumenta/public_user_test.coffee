PublicUser = require '../../lib/argumenta/public_user'
fixtures   = require '../../test/fixtures'
should = require 'should'

describe 'PublicUser', ->

  describe 'new PublicUser( username, joinDate, gravatarId )', ->
    it 'should create a new public user instance', ->
      data = fixtures.validPublicUserData()
      user = new PublicUser data.username, data.join_date, data.gravatar_id
      user.should.be.an.instanceOf PublicUser
      user.username.should.equal data.username
      user.joinDate.should.equal data.join_date
      user.gravatarId.should.equal data.gravatar_id
      user.validate().should.equal true

  describe 'new PublicUser( params )', ->
    it 'should create a new public user instance', ->
      data = fixtures.validPublicUserData()
      user1 = new PublicUser data
      user2 = new PublicUser data.username, data.join_date, data.gravatar_id
      should.ok user1.equals( user2 )

    it 'should not contain private fields', ->
      data = fixtures.validPublicUserData()
      data.email = fixtures.validEmail()
      data.passwordHash = fixtures.validPasswordHash()
      user = new PublicUser data
      should.not.exist user.email
      should.not.exist user.passwordHash

  describe 'data()', ->
    it 'should return the user info as a plain object', ->
      user = fixtures.validPublicUser()
      data = user.data()
      data.should.eql {
        username:     user.username
        join_date:    user.joinDate.toISOString()
        gravatar_id:  user.gravatarId
      }

    it 'should include any metadata', ->
      user = fixtures.validPublicUser()
      user.metadata = fixtures.validUserMetadata()
      data = user.data()
      data.metadata.should.equal user.metadata

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
