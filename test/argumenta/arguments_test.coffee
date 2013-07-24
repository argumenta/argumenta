Argumenta = require '../../lib/argumenta'
Storage   = require '../../lib/argumenta/storage'
Arguments = require '../../lib/argumenta/arguments'
fixtures  = require '../../test/fixtures'
should    = require 'should'

describe 'Arguments', ->

  options =
    storageType: 'local'
    host: 'testing.argumenta.io'

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
