
config    = require '../../config'
Argumenta = require '../../lib/argumenta'
Storage   = require '../../lib/argumenta/storage'
Search    = require '../../lib/argumenta/search'
fixtures  = require '../../test/fixtures'
should    = require 'should'

describe 'Search', ->

  options =
    storageType: 'postgres'
    storageUrl:  config.postgresUrl
    host: 'testing.argumenta.io'

  argumenta = new Argumenta options

  beforeEach (done) ->
    argumenta.storage.clearAll {quick: true}, (err) ->
      should.not.exist err
      done()

  after (done) ->
    argumenta.storage.clearAll {}, (err) ->
      should.not.exist err
      done()

  withArgument = (callback) ->
    {username} = data = fixtures.uniqueUserData()
    arg = fixtures.uniqueArgument()
    argumenta.users.create data, (er1, user) ->
      argumenta.arguments.commit username, arg, (er2, commit) ->
        argumenta.storage.getArgument arg.sha1(), (er3, argument) ->
          [er1, er2, er3].should.eql [1..3].map -> null
          return callback user, commit, argument

  describe 'new Search( argumenta, storage )', ->
    it 'should create a new search instance', ->
      argumenta = new Argumenta options
      search = new Search( argumenta, argumenta.storage )
      search.should.be.an.instanceOf Search
      search.argumenta.should.be.an.instanceOf Argumenta
      search.storage.should.be.an.instanceOf Storage

  describe 'query( query, options, callback )', ->
    it 'should get arguments matching the given query', (done) ->
      withArgument (user, commit, argument) ->
        query = argument.title
        argumenta.search.query query, {}, (err, results) ->
          results.arguments.length.should.equal 1
          arg = results.arguments[0]
          should.ok arg.equals argument
          should.ok arg.commit.equals commit
          done()
