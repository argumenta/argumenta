Comment     = require '../../lib/argumenta/comment'
fixtures    = require '../../test/fixtures'
_           = require 'underscore'
should      = require 'should'

describe 'Comment', ->

  defaultParams =
    commentId    : fixtures.validCommentId()
    author       : fixtures.validCommentAuthor()
    commentDate  : fixtures.validCommentDate()
    commentText  : fixtures.validCommentText()
    discussionId : fixtures.validDiscussionId()
    gravatarId   : fixtures.validGravatarId()

  describe 'new Comment( params )', ->

    it 'should create a new comment instance', ->
      params = defaultParams

      comment = new Comment params

      comment.should.be.an.instanceOf Comment
      comment.commentId.should.equal params.commentId
      comment.author.should.equal params.author
      comment.commentDate.should.equal params.commentDate
      comment.commentText.should.equal params.commentText
      comment.discussionId.should.equal params.discussionId
      comment.gravatarId.should.equal params.gravatarId
      comment.validate().should.equal true

  describe 'equals( comment )', ->

    it 'should return true if comments are equal', ->
      params = defaultParams
      comment1 = new Comment params
      comment2 = new Comment params
      should.ok comment1.equals comment2

    it 'should return false if comments are not equal', ->
      params = defaultParams
      comment1 = new Comment params
      comment2 = new Comment _.extend({}, params, {author: 'Senpai'})
      should.ok !comment1.equals comment2

  describe 'data()', ->

    it "should include the gravatar id", ->
      params = defaultParams
      comment = new Comment params
      data = comment.data()
      data.gravatar_id.should.equal params.gravatarId

  describe 'validate()', ->

    it 'should return false if commentId is invalid', ->
      params = _.extend {}, defaultParams, {commentId: 'bad-id'}
      comment = new Comment params
      comment.validate().should.equal false

    it 'should return false if author is invalid', ->
      params = _.extend {}, defaultParams, {author: ''}
      comment = new Comment params
      comment.validate().should.equal false

    it 'should return false if commentDate is invalid', ->
      params = _.extend {}, defaultParams, {commentDate: ''}
      comment = new Comment params
      comment.validate().should.equal false

    it 'should return false if commentText is invalid', ->
      params = _.extend {}, defaultParams, {commentText: ''}
      comment = new Comment params
      comment.validate().should.equal false

    it 'should return false if discussionId is invalid', ->
      params = _.extend {}, defaultParams, {discussionId: 'bad-id'}
      comment = new Comment params
      comment.validate().should.equal false
