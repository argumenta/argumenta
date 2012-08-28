Argumenta = require '../../lib/argumenta'
Auth      = require '../../lib/argumenta/auth'
User      = require '../../lib/argumenta/user'
should = require 'should'

describe 'Auth', ->

  describe 'Auth.hashPassword()', ->
    
    it 'should hash a password successfully', (done) ->
      password = 'secret'
      Auth.hashPassword password, (err, hash) ->
        should.not.exist err
        should.ok typeof hash is 'string'
        hash.should.match /\$.+\$.+\$.+/
        done()

  describe 'Auth.verifyPassword()', ->

    it 'should verify a password successfully', (done) ->
      hash = '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
      password = 'tester12'
      Auth.verifyPassword password, hash, (err, status) ->
        should.not.exist err
        should.exist status
        status.should.equal true
        done()

    it 'should deny an incorrect password', (done) ->
      hash = '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
      password = 'tester12'
      Auth.verifyPassword password, hash, (err, status) ->
        should.not.exist err
        should.exist status
        status.should.equal true
        done()

  describe 'auth.verifyLogin()', ->

    argumenta = new Argumenta storageType: 'local'

    before (done) ->
      username = 'tester'
      password = 'tester12'
      email = 'tester@xyz.com'
      argumenta.users.create username, password, email, (err, user) ->
        should.not.exist err
        done()

    it 'should authenticate a valid user login', (done) ->
      username = 'tester'
      password = 'tester12'
      argumenta.auth.verifyLogin username, password, (err, status) ->
        should.not.exist err
        should.exist status
        status.should.equal true
        done()

    it 'should deny an invalid user login', (done) ->
      username = 'tester'
      password = 'wrong!'
      argumenta.auth.verifyLogin username, password, (err, status) ->
        should.not.exist err
        should.exist status
        status.should.equal false
        done()
