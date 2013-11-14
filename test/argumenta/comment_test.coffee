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
      comment.validate().should.equal true

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
