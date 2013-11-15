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
      should.not.exist discussion.discussionId
      should.not.exist discussion.updatedAt
      discussion.validate().should.equal true

  describe 'equals( discussion )', ->

    it 'should return true if discussions are equal', ->
      params = defaultParams
      discussion1 = new Discussion params
      discussion2 = new Discussion params
      should.ok discussion1.equals discussion2

    it 'should return false if discussions are not equal', ->
      params = defaultParams
      discussion1 = new Discussion params
      discussion2 = new Discussion _.extend({}, params, {creator: 'Senpai'})
      should.ok !discussion1.equals discussion2

  describe 'validate()', ->

    it 'should return false if discussionId is invalid', ->
      params = _.extend {}, defaultParams, {discussionId: 'bad-id'}
      discussion = new Discussion params
      discussion.validate().should.equal false

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
