config       = require '../../../config'
Argumenta    = require '../../../lib/argumenta'
Storage      = require '../../../lib/argumenta/storage'
Propositions = require '../../../lib/argumenta/collections/propositions'
fixtures     = require '../../../test/fixtures'
should       = require 'should'

describe 'Propositions', ->

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

  withProposition = (callback) ->
    {username} = data = fixtures.uniqueUserData()
    prop = fixtures.uniqueProposition()
    argumenta.users.create data, (er1, user) ->
      argumenta.propositions.commit username, prop, (er2, commit) ->
        argumenta.storage.getProposition prop.sha1(), (er3, proposition) ->
          [er1, er2, er3].should.eql [1..3].map -> null
          return callback user, commit, proposition

  describe 'new Propositions( argumenta, storage )', ->
    it 'should create a new propositions instance', ->
      argumenta = new Argumenta options
      props = new Propositions( argumenta, argumenta.storage )
      props.should.be.an.instanceOf Propositions
      props.argumenta.should.be.an.instanceOf Argumenta
      props.storage.should.be.an.instanceOf Storage

  describe 'propositions.commit( username, proposition, callback )', ->
    it 'should commit the proposition given existing user and valid proposition', (done) ->
      {username} = data = fixtures.validUserData()
      prop = fixtures.validProposition()
      a = new Argumenta options
      a.users.create data, (er1, user) ->
        a.propositions.commit username, prop, (er2, commit) ->
          a.storage.getCommit commit.sha1(), (er3, retrievedCommit) ->
            a.storage.getProposition prop.sha1(), (er4, retrievedProposition) ->
              [er1, er2, er3, er4].should.eql [1..4].map -> null
              should.ok commit.equals retrievedCommit
              should.ok prop.equals retrievedProposition
              commit.host.should.equal 'testing.argumenta.io'
              done()

  describe 'propositions.get( hashes, callback )', ->
    it 'should get proposition resources by hashes', (done) ->
      withProposition (user1, commit1, proposition1) ->
        withProposition (user2, commit2, proposition2) ->
          hashes = [ proposition1.sha1(), proposition2.sha1() ]
          argumenta.propositions.get hashes, (err, props) ->
            should.ok props[0].equals proposition1
            should.ok props[1].equals proposition2
            done()

    it 'should include metadata for propositions', (done) ->
      withProposition (user1, commit1, proposition) ->
        hashes = [ proposition.sha1() ]
        argumenta.propositions.get hashes, (err, props) ->
          should.exist props[0].metadata
          done()

    it 'should include any commit for propositions', (done) ->
      withProposition (user1, commit1, proposition) ->
        hashes = [ proposition.sha1() ]
        argumenta.propositions.get hashes, (err, props) ->
          should.exist props[0].commit
          done()

  describe 'propositions.latest( options, callback )', ->
    it 'should get latest propositions', (done) ->
      withProposition (user1, commit1, proposition1) ->
        withProposition (user2, commit2, proposition2) ->
          argumenta.propositions.latest {}, (err, props) ->
            should.not.exist err
            props.length.should.equal 2
            should.ok props[0].equals proposition2
            should.ok props[1].equals proposition1
            done()
