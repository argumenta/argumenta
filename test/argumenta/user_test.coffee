User   = require '../../lib/argumenta/user'
bcrypt = require 'bcrypt'
should = require 'should'

describe 'User', ->

  describe 'new User', ->
    it 'should create a user instance from storable attributes', ->

      # Storable fields includes password hash
      params =
        username:      'tester'
        email:         'tester@xyz.com'
        password_hash: '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'

      # Create user syncronously
      user = new User params

      # Test values
      user.should.be.an.instanceof     User
      user.username.should.equal      'tester'
      user.email.should.equal         'tester@xyz.com'
      user.password_hash.should.equal '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
      should.not.exist user.password

      # Validate user
      should.ok user.validate()

      # Verify password
      should.ok bcrypt.compareSync 'tester12', user.password_hash

  describe 'User.validatePassword()', ->
    it 'should fail if password is less than 6 characters', ->
      validatorFor = (pass) ->
        return -> User.validatePassword( pass )
      validatorFor('12345').should.throw
      validatorFor('123456').should.not.throw

  describe 'validate()', ->
    username = 'tester'
    password_hash = '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
    email = 'tester@xyz.com'

    it 'should return true if the user is valid', ->
      user = new User {username, password_hash, email}
      user.validate().should.equal true

    it 'should return false if the username is missing', ->
      user = new User {password_hash, email}
      user.validate().should.equal false

    it 'should return false if the username is blank', ->
      user = new User {username: '', password_hash, email}
      user.validate().should.equal false

    it 'should return false if the password_hash is missing', ->
      user = new User {username, email}
      user.validate().should.equal false

    it 'should return false if the email is invalid', ->
      user = new User {username, password_hash, email: 'bad-email'}
      user.validate().should.equal false
