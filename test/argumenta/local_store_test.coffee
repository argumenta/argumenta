LocalStore = require '../../lib/argumenta/storage/local_store'
User       = require '../../lib/argumenta/user'

should = require 'should'

describe 'LocalStore', ->

  store = new LocalStore()
  tester = new User
    username: 'tester'
    password: 'tester12'
    email:    'tester@xyz.com'

  describe 'addUser()', ->
    it 'should add a user successfully', (done) ->
      store.addUser tester, (err) ->
        should.not.exist err
        done()

  describe 'getUserByName()', ->
    it 'should get a stored user', (done) ->
      store.getUserByName 'tester', (err, user) ->
        should.not.exist err
        user.username.should.equal 'tester'
        done()

  describe 'clearAll()', ->
    it 'should delete all stored entities', (done) ->
      store.clearAll (err) ->
        should.not.exist err
        # Check that user is really gone
        store.getUserByName 'tester', (err, user)->
          should.exist err
          should.not.exist user
          done()

  it 'should have a custom error class', ->
    LocalStore.Error.name.should.equal 'LocalStoreError'
    (new LocalStore.Error "message").should.be.an.instanceof Error
    (new LocalStore.Error "message").should.be.an.instanceof LocalStore.Error

  describe 'LocalStoreError', ->

    it 'should support error messages', ->
      err = new LocalStore.Error "a message"
      err.message.should.equal "a message"

    it 'should have an error stack', ->
      prevErr = new Error "previous message"
      err = new LocalStore.Error "message", prevErr

      err.errStack.length.should.equal 2
      err.errStack[0].should.equal prevErr
      err.errStack[1].should.equal err
