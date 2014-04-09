Argumenta = require '../../../lib/argumenta'
Storage   = require '../../../lib/argumenta/storage'
Tags      = require '../../../lib/argumenta/collections/tags'
fixtures  = require '../../../test/fixtures'
should    = require 'should'

describe 'Tags', ->

  options =
    storageType: 'local'
    host: 'testing.argumenta.io'

  describe 'new Tags( argumenta, storage )', ->
    it 'should create a new commits instance', ->
      argumenta = new Argumenta options
      tags = new Tags( argumenta, argumenta.storage )
      tags.should.be.an.instanceOf Tags
      tags.argumenta.should.be.an.instanceOf Argumenta
      tags.storage.should.be.an.instanceOf Storage

  describe 'commit( username, tag, callback )', ->
    it 'should commit the tag given existing user and valid tag', (done) ->
      {username} = data = fixtures.validUserData()
      tag = fixtures.validSupportTag()
      argument = fixtures.validArgument()
      a = new Argumenta options
      a.users.create data, (er1, user) ->
        a.arguments.commit username, argument, (er2, commit) ->
          a.tags.commit username, tag, (er3, commit) ->
            a.storage.getCommit commit.sha1(), (er4, retrievedCommit) ->
              a.storage.getTag tag.sha1(), (er5, retrievedTag) ->
                [er1, er2, er3, er4, er5].should.eql [1..5].map -> null
                should.ok tag.equals retrievedTag
                should.ok commit.equals retrievedCommit
                commit.host.should.equal 'testing.argumenta.io'
                done()
