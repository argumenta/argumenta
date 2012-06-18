User   = require '../../lib/argumenta/user'
bcrypt = require 'bcrypt'
should = require 'should'

describe 'User', ->

  describe 'User.new()', ->
    it 'should create a new user instance asynchronously from user input', (done) ->

      # User input includes plaintext password
      params =
        username: 'tester'
        password: 'tester12'
        email:    'tester@xyz.com'

      # Create user asyncronously
      User.new params, (err, user) ->

        # Test values
        should.not.exist err
        should.not.exist user.password
        user.should.be.an.instanceof     User
        user.username.should.equal      'tester'
        user.email.should.equal         'tester@xyz.com'
        user.password_hash.should.match /\$.+\$.+\$.+/

        # Validate user
        should.ok user.validate()

        # Verify password
        should.ok bcrypt.compareSync 'tester12', user.password_hash
        done()

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
