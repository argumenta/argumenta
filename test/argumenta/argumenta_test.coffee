Argumenta   = require '../../lib/argumenta'
Auth        = require '../../lib/argumenta/auth'
Storage     = require '../../lib/argumenta/storage'
Arguments   = require '../../lib/argumenta/arguments'
Users       = require '../../lib/argumenta/users'
LocalStore  = require '../../lib/argumenta/storage/local_store'

describe 'Argumenta', ->
  describe 'new Argumenta( opts )', ->
    it 'should create a new argumenta instance', ->
      argumenta = new Argumenta storageType: 'local'
      argumenta.should.be.an.instanceOf Argumenta
      argumenta.auth.should.be.an.instanceof Auth
      argumenta.storage.store.should.be.an.instanceOf LocalStore
      argumenta.arguments.should.be.an.instanceof Arguments
      argumenta.users.should.be.an.instanceof Users
