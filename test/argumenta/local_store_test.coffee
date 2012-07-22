LocalStore = require '../../lib/argumenta/storage/local_store'
User       = require '../../lib/argumenta/user'

should = require 'should'

describe 'LocalStore', ->

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
