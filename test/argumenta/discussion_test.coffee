Discussion  = require '../../lib/argumenta/discussion'
fixtures    = require '../../test/fixtures'
_           = require 'underscore'
should      = require 'should'

describe 'Discussion', ->

  defaultParams =
    targetType  : 'argument'
    targetSha1  : fixtures.validArgument().sha1()
    targetOwner : fixtures.validUser().username
    creator     : fixtures.validUser().username
    createdAt   : new Date()

  describe 'new Discussion( params )', ->

    it 'should create a new discussion instance', ->
      params = defaultParams

      discussion = new Discussion params

      discussion.should.be.an.instanceOf Discussion
      discussion.targetType.should.equal params.targetType
      discussion.targetSha1.should.equal params.targetSha1
      discussion.targetOwner.should.equal params.targetOwner
      discussion.creator.should.equal params.creator
      discussion.createdAt.should.equal params.createdAt
      should.not.exist discussion.updatedAt
      discussion.validate().should.equal true

  describe 'validate()', ->

    it 'should return false if targetType is invalid', ->
      params = _.extend {}, defaultParams, {targetType: 'bad-type'}
      discussion = new Discussion params
      discussion.validate().should.equal false

    it 'should return false if targetSha1 is invalid', ->
      params = _.extend {}, defaultParams, {targetSha1: 'bad-sha1'}
      discussion = new Discussion params
      discussion.validate().should.equal false

    it 'should return false if targetOwner is invalid', ->
      params = _.extend {}, defaultParams, {targetOwner: ''}
      discussion = new Discussion params
      discussion.validate().should.equal false

    it 'should return false if creator is invalid', ->
      params = _.extend {}, defaultParams, {creator: ''}
      discussion = new Discussion params
      discussion.validate().should.equal false

    it 'should return false if createdAt is invalid', ->
      params = _.extend {}, defaultParams, {createdAt: null}
      discussion = new Discussion params
      discussion.validate().should.equal false

    it 'should return false if updatedAt is invalid', ->
      params = _.extend {}, defaultParams, {updatedAt: 'bad-date'}
      discussion = new Discussion params
      discussion.validate().should.equal false
