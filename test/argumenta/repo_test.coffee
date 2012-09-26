should     = require 'should'
fixtures   = require '../../test/fixtures'
Repo       = require '../../lib/argumenta/repo'

describe 'Repo', ->

  describe 'new Repo( user, reponame, commit, target )', ->
    it 'should create a new repo instance', ->
      user = fixtures.validPublicUser()
      reponame = fixtures.validRepoName()
      commit = fixtures.validCommit()
      target = fixtures.validArgument()
      repo = new Repo( user, reponame, commit, target )
      repo.should.be.an.instanceof Repo
      repo.validate().should.equal true

  describe 'new Repo( options )', ->
    it 'should create a new repo instance', ->
      options = fixtures.validRepo().data()
      repo = new Repo( options )
      repo.validate().should.equal true

  describe 'data()', ->
    it 'should return the repo data as a plain object', ->
      repo = fixtures.validRepo()
      should.ok repo.equals new Repo repo.data()

  describe 'equals( repo )', ->
    it 'should return true if repos are equal', ->
      repo1 = fixtures.validRepo()
      repo2 = fixtures.validRepo()
      should.ok repo1.equals repo2

    it 'should return false if repos are not equal', ->
      repo1 = fixtures.uniqueRepo()
      repo2 = fixtures.uniqueRepo()
      should.ok repo1.equals( repo2 ) is false

  describe 'validate()', ->
    it 'should return true if the repo is valid', ->
      repo = fixtures.validRepo()
      repo.validate().should.equal true

    it 'should return false if the reponame is missing', ->
      repo = fixtures.validRepo()
      repo.reponame = null
      repo.validate().should.equal false

    it 'should return false if the reponame is above the max length', ->
      repo = fixtures.validRepo()
      repo.reponame = ('a' for i in [0..Repo.MAX_REPONAME_LENGTH]).join ''
      repo.validate().should.equal false

    it 'should return false if the user is missing', ->
      repo = fixtures.validRepo()
      repo.user = null
      repo.validate().should.equal false

    it 'should return false if the commit is missing', ->
      repo = fixtures.validRepo()
      repo.commit = null
      repo.validate().should.equal false

    it 'should return false if the target is missing', ->
      repo = fixtures.validRepo()
      repo.target = null
      repo.validate().should.equal false
