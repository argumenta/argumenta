config       = require '../../config'
Argumenta    = require '../../lib/argumenta'
Storage      = require '../../lib/argumenta/storage'
Publications = require '../../lib/argumenta/publications'
fixtures     = require '../../test/fixtures'
should       = require 'should'

describe 'Publications', ->

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

  withProposition = (callback) ->
    {username} = data = fixtures.uniqueUserData()
    prop = fixtures.uniqueProposition()
    argumenta.users.create data, (er1, user) ->
      argumenta.propositions.commit username, prop, (er2, commit) ->
        argumenta.storage.getProposition prop.sha1(), (er3, proposition) ->
          [er1, er2, er3].should.eql [1..3].map -> null
          return callback user, commit, proposition

  describe 'new Publications( argumenta, storage )', ->
    it 'should create a new propositions instance', ->
      argumenta = new Argumenta options
      publications = new Publications( argumenta, argumenta.storage )
      publications.should.be.an.instanceOf Publications
      publications.argumenta.should.be.an.instanceOf Argumenta
      publications.storage.should.be.an.instanceOf Storage

  describe 'publications.byUsernames( usernames, options, callback )', ->
    it 'should get latest publications by usernames', (done) ->
      withArgument (user1, commit1, publication1) ->
        withProposition (user2, commit2, publication2) ->
          usernames = [user1.username, user2.username]
          options = {}
          argumenta.publications.byUsernames usernames, options, (err, publications) ->
            should.not.exist err
            publications.length.should.equal 2
            should.ok publications[0].equals publication2
            should.ok publications[1].equals publication1
            done()

  describe 'publications.get( hashes, callback )', ->
    it 'should get proposition resources by hashes', (done) ->
      withArgument (user1, commit1, publication1) ->
        withProposition (user2, commit2, publication2) ->
          hashes = [publication1.sha1(), publication2.sha1()]
          argumenta.publications.get hashes, (err, publications) ->
            should.ok publications[0].equals publication1
            should.ok publications[1].equals publication2
            done()
