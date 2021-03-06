config      = require '../../../config'
Argumenta = require '../../../lib/argumenta'
Storage   = require '../../../lib/argumenta/storage'
Arguments = require '../../../lib/argumenta/collections/arguments'
fixtures  = require '../../../test/fixtures'
should    = require 'should'

describe 'Arguments', ->

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

  describe 'new Arguments( argumenta, storage )', ->
    it 'should create a new arguments instance', ->
      argumenta = new Argumenta options
      args = new Arguments( argumenta, argumenta.storage )
      args.should.be.an.instanceOf Arguments
      args.argumenta.should.be.an.instanceOf Argumenta
      args.storage.should.be.an.instanceOf Storage

  describe 'arguments.commit( username, argument, callback )', ->
    it 'should commit the argument given existing user and valid argument', (done) ->
      {username} = data = fixtures.validUserData()
      argument = fixtures.validArgument()
      a = new Argumenta options
      a.users.create data, (er1, user) ->
        a.arguments.commit username, argument, (er2, commit) ->
          a.storage.getCommit commit.sha1(), (er3, retrievedCommit) ->
            a.storage.getArgument argument.sha1(), (er4, retrievedArgument) ->
              a.storage.getRepoHash username, argument.repo(), (er5, hash) ->
                [er1, er2, er3, er4, er5].should.eql [1..5].map -> null
                should.ok commit.equals retrievedCommit
                should.ok argument.equals retrievedArgument
                hash.should.equal commit.sha1()
                commit.host.should.equal 'testing.argumenta.io'
                done()

    it 'should set the commit parent and update existing repos', (done) ->
      withArgument (user1, commit1, argument1) ->
        username = user1.username
        reponame = argument1.repo()
        argument2 = fixtures.uniqueArgument()
        argument2.title = argument1.title
        a = new Argumenta options
        a.arguments.commit username, argument2, (err, commit2) ->
          should.not.exist err
          commit2.parentSha1s.length.should.equal 1
          commit2.parentSha1s[0].should.equal commit1.sha1()
          a.storage.getRepoHash username, reponame, (err, hash) ->
            should.not.exist err
            hash.should.equal commit2.sha1()
            done()

  describe 'arguments.get( hashes, callback )', ->
    it 'should get argument resources by hashes', (done) ->
      withArgument (user1, commit1, argument1) ->
        withArgument (user2, commit2, argument2) ->
          hashes = [ argument1.sha1(), argument2.sha1() ]
          argumenta.arguments.get hashes, (err, args) ->
            should.ok args[0].equals argument1
            should.ok args[1].equals argument2
            done()

    it 'should include metadata for propositions', (done) ->
      withArgument (user1, commit1, argument1) ->
        hashes = [ argument1.sha1() ]
        argumenta.arguments.get hashes, (err, args) ->
          should.exist args[0].propositions[0].metadata
          done()

  describe 'arguments.latest( options, callback )', ->
    it 'should get latest arguments', (done) ->
      withArgument (user1, commit1, argument1) ->
        withArgument (user2, commit2, argument2) ->
          argumenta.arguments.latest {}, (err, args) ->
            should.not.exist err
            args.length.should.equal 2
            should.ok args[0].equals argument2
            should.ok args[1].equals argument1
            done()
