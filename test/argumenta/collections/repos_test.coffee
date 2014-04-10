config      = require '../../../config'
Argumenta = require '../../../lib/argumenta'
Storage   = require '../../../lib/argumenta/storage'
Repo      = require '../../../lib/argumenta/repo'
Repos     = require '../../../lib/argumenta/collections/repos'
fixtures  = require '../../../test/fixtures'
should    = require 'should'

describe 'Repos', ->

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

  withRepo = (callback) ->
    withArgument (user, commit, argument) ->
      username = user.username
      reponame = argument.repo()
      argumenta.storage.addRepo username, reponame, commit.sha1(), (err) ->
        should.not.exist err
        key = [ username, reponame ]
        keys = [ key ]
        argumenta.storage.getRepos keys, (err, repos) ->
          should.not.exist err
          repos.length.should.equal 1
          repo = repos[0]
          should.ok repo.equals new Repo user, reponame, commit, argument
          return callback user, repo

  describe 'new Repos( argumenta, storage )', ->
    it 'should create a new repos instance', ->
      argumenta = new Argumenta options
      repos = new Repos( argumenta, argumenta.storage )
      repos.should.be.an.instanceOf Repos
      repos.argumenta.should.be.an.instanceOf Argumenta
      repos.storage.should.be.an.instanceOf Storage

  describe 'repos.get( hashes, callback )', ->
    it 'should get repo resources by hashes', (done) ->
      withRepo (user1, repo1) ->
        withRepo (user2, repo2) ->
          keys = [
            [ user1.username, repo1.reponame ]
            [ user2.username, repo2.reponame ]
          ]
          argumenta.repos.get keys, (err, repos) ->
            should.not.exist err
            should.ok repos[0].equals repo1
            should.ok repos[1].equals repo2
            done()

  describe 'repos.latest( options, callback )', ->
    it 'should get latest repos', (done) ->
      withRepo (user1, repo1) ->
        withRepo (user2, repo2) ->
          options = {}
          argumenta.repos.latest options, (err, repos) ->
            should.not.exist err
            repos.length.should.equal 2
            should.ok repos[0].equals repo2
            should.ok repos[1].equals repo1
            done()
