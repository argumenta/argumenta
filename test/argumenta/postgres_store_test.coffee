pg            = require 'pg'
PostgresStore = require '../../lib/argumenta/storage/postgres_store'
Session       = require '../../lib/argumenta/storage/postgres_session'
config        = require '../../config'

should = require 'should'

describe 'PostgresStore', ->

  pgUrl = config.postgresUrl

  it 'should have a custom error class', ->
    PostgresStore.Error.name.should.equal 'PostgresStoreError'
    (new PostgresStore.Error "message").should.be.an.instanceof Error
    (new PostgresStore.Error "message").should.be.an.instanceof PostgresStore.Error

  describe 'new PostgresStore( connectionUrl )', ->
    it 'should init a new PostgresStore instance', ->
      store = new PostgresStore pgUrl
      store.should.be.an.instanceof PostgresStore
      store.connectionUrl.should.equal pgUrl

  describe 'session()', ->
    it 'should return a new PostgresSession', (done) ->
      store = new PostgresStore pgUrl
      store.session (err, session) ->
        should.not.exist err
        session.should.be.an.instanceof Session
        session.cancel (err) ->
          should.not.exist err
          done()
