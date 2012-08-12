should = require 'should'
Commit = require '../../lib/argumenta/objects/commit'

describe 'Commit', ->

  targetType = 'argument'
  targetSha1 = '39cb3925a38f954cf4ca12985f5f948177f6da5e'
  committer = 'tester'
  commitDate = '1970-01-01T00:00:00Z'
  parentASha1 = '0123456789abcdef000000000000000000000000'
  parentBSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'

  describe 'new Commit( targetType, targetSha1, committer )', ->
    it 'should create a new commit instance', ->
      commit = new Commit( targetType, targetSha1, committer )
      commit.should.be.an.instanceOf Commit
      commit.targetType.should.equal 'argument'
      commit.targetSha1.should.equal '39cb3925a38f954cf4ca12985f5f948177f6da5e'
      commit.committer.should.equal 'tester'
      commit.commitDate.should.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/
      should.ok Date.now() - new Date(commit.commitDate) < 2000

  describe 'new Commit( targetType, targetSha1, committer, commitDate, parentSha1s )', ->
    it 'should create a new commit instance', ->
      commit = new Commit( targetType, targetSha1, committer, null, [parentASha1, parentBSha1] )
      commit.validate().should.equal true

  describe 'objectRecord()', ->
    it 'should return the commit object record text', ->
      commit = new Commit( targetType, targetSha1, committer, commitDate )
      record = commit.objectRecord()
      record.should.equal """
        commit

        argument 39cb3925a38f954cf4ca12985f5f948177f6da5e
        committer tester
        commit_date 1970-01-01T00:00:00Z

      """

    it 'should show any parents in the object record text', ->
      commit = new Commit( targetType, targetSha1, committer, commitDate, [parentASha1, parentBSha1] )
      record = commit.objectRecord()
      record.should.equal """
        commit

        argument 39cb3925a38f954cf4ca12985f5f948177f6da5e
        parent 0123456789abcdef000000000000000000000000
        parent 1a1a1a1a1a1a1a1a000000000000000000000000
        committer tester
        commit_date 1970-01-01T00:00:00Z

      """

  describe 'sha1()', ->
    it 'should return the sha1 sum of the object record', ->
      commit = new Commit( targetType, targetSha1, committer, commitDate )
      sha1 = commit.sha1()
      sha1.should.equal 'fa95fa7684ec4156c5616931d8e233a3397ba9e5'

  describe 'validate()', ->
    it 'should return true for a valid Commit instance', ->
      commit = new Commit( targetType, targetSha1, committer )
      commit.validate().should.equal true

    it 'should return false if target type is invalid', ->
      commit = new Commit 'bad-type', targetSha1, committer
      commit.validate().should.equal false

    it 'should return false if target sha1 is invalid', ->
      commit = new Commit targetType, 'bad-sha1', committer
      commit.validate().should.equal false

    it 'should return false if committer is invalid', ->
      commit = new Commit targetType, targetSha1, 'bad name'
      commit.validate().should.equal false

    it 'should return false if commit date is invalid', ->
      commit = new Commit( targetType, targetSha1, committer, 'bad date' )
      commit.validate().should.equal false

    it 'should return true with zero parent sha1s', ->
      commit = new Commit( targetType, targetSha1, committer, null, [ ])
      commit.validate().should.equal true

    it 'should return true with one parent sha1', ->
      commit = new Commit( targetType, targetSha1, committer, null, [ parentASha1 ])
      commit.validate().should.equal true

    it 'should return true with two parent sha1s', ->
      commit = new Commit( targetType, targetSha1, committer, null, [ parentASha1, parentBSha1 ])
      commit.validate().should.equal true

    it 'should return false if a parent sha1 is null', ->
      commit = new Commit( targetType, targetSha1, committer, null, [ null ] )
      commit.validate().should.equal false

    it 'should return false if a parent sha1 is invalid', ->
      commit = new Commit( targetType, targetSha1, committer, null, [ 'bad-sha1' ] )
      commit.validate().should.equal false

  describe 'Commit.formatDate( date )', ->
    it 'should format a date as a ISO 8601 string', ->
      date = new Date 0
      dateString = Commit.formatDate( date )
      dateString.should.equal '1970-01-01T00:00:00Z'
