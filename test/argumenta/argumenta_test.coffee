Argumenta    = require '../../lib/argumenta'
Auth         = require '../../lib/argumenta/auth'
Storage      = require '../../lib/argumenta/storage'
Arguments    = require '../../lib/argumenta/collections/arguments'
Comments     = require '../../lib/argumenta/collections/comments'
Discussions  = require '../../lib/argumenta/collections/discussions'
Propositions = require '../../lib/argumenta/collections/propositions'
Publications = require '../../lib/argumenta/collections/publications'
Users        = require '../../lib/argumenta/collections/users'
Search       = require '../../lib/argumenta/search'
LocalStore   = require '../../lib/argumenta/storage/local_store'

describe 'Argumenta', ->
  describe 'new Argumenta( opts )', ->
    it 'should create a new argumenta instance', ->
      argumenta = new Argumenta storageType: 'local'
      argumenta.should.be.an.instanceOf Argumenta
      argumenta.auth.should.be.an.instanceof Auth
      argumenta.storage.store.should.be.an.instanceOf LocalStore
      argumenta.arguments.should.be.an.instanceof Arguments
      argumenta.comments.should.be.an.instanceof Comments
      argumenta.discussions.should.be.an.instanceof Discussions
      argumenta.propositions.should.be.an.instanceof Propositions
      argumenta.publications.should.be.an.instanceof Publications
      argumenta.search.should.be.an.instanceof Search
      argumenta.users.should.be.an.instanceof Users
