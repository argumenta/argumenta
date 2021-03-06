should   = require 'should'
fixtures = require '../../../test/fixtures'
Commit   = require '../../../lib/argumenta/objects/commit'

describe 'Commit', ->

  targetType = 'argument'
  targetSha1 = '39cb3925a38f954cf4ca12985f5f948177f6da5e'
  committer = 'tester'
  commitDate = '1970-01-01T00:00:00Z'
  parentASha1 = '0123456789abcdef000000000000000000000000'
  parentBSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'
  host = 'testing.argumenta.io'

  describe 'new Commit( targetType, targetSha1, committer )', ->

    it 'should create a new commit instance', ->
      commit = new Commit( targetType, targetSha1, committer )
      commit.should.be.an.instanceOf Commit
      commit.targetType.should.equal 'argument'
      commit.targetSha1.should.equal '39cb3925a38f954cf4ca12985f5f948177f6da5e'
      commit.committer.should.equal 'tester'
      commit.commitDate.should.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/
      should.ok Date.now() - new Date(commit.commitDate) < 2000

    it 'should create a new commit with proposition target', ->
      prop = fixtures.validProposition()
      commit = new Commit('proposition', prop.sha1(), committer)
      commit.targetType.should.equal 'proposition'
      should.ok commit.validate()

  describe 'new Commit( options )', ->

    it 'should create a new commit instance', ->
      commit1 = fixtures.validCommit()
      commit2 = new Commit( commit1.data() )
      should.ok commit1.equals commit2

    it 'should create a new commit with host', ->
      data = fixtures.validCommitData()
      data.host = fixtures.validHost()
      commit = new Commit( data )
      commit.host.should.equal data.host

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

    it 'should show the host in object record text', ->
      commit = new Commit( targetType, targetSha1, committer, commitDate, [], host )
      record = commit.objectRecord()
      record.should.equal """
        commit

        argument 39cb3925a38f954cf4ca12985f5f948177f6da5e
        committer tester
        commit_date 1970-01-01T00:00:00Z
        host testing.argumenta.io

      """

  describe 'sha1()', ->

    it 'should return the sha1 sum of the object record', ->
      commit = new Commit( targetType, targetSha1, committer, commitDate )
      sha1 = commit.sha1()
      sha1.should.equal 'fa95fa7684ec4156c5616931d8e233a3397ba9e5'

  describe 'data()', ->

    it 'should return a plain object with commit data', ->
      commit = new Commit targetType, targetSha1, committer, commitDate, [], host
      data = commit.data()
      data.should.eql {
        object_type: 'commit'
        sha1: commit.sha1()
        target_type: commit.targetType
        target_sha1: commit.targetSha1
        committer: commit.committer
        commit_date: commit.commitDate
        parent_sha1s: commit.parentSha1s
        host: commit.host
      }

  describe 'equals()', ->

    it 'should return true if commits are equal', ->
      commitA = new Commit targetType, targetSha1, committer, commitDate
      commitB = new Commit targetType, targetSha1, committer, commitDate
      commitA.equals(commitB).should.equal true

    it 'should return false if commits are not equal', ->
      commitA = new Commit targetType, targetSha1, committer, commitDate
      commitB = new Commit targetType, targetSha1, 'diff-committer', commitDate
      commitA.equals(commitB).should.equal false

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

    it 'should return true if host is valid', ->
      commit = new Commit( targetType, targetSha1, committer, null, [], host )
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

    it 'should return false if host is invalid', ->
      commit = new Commit( targetType, targetSha1, committer, null, [], 'bad-host' )
      commit.validate().should.equal false

  describe 'Commit.formatDate( date )', ->

    it 'should format a date as a ISO 8601 string', ->
      date = new Date 0
      dateString = Commit.formatDate( date )
      dateString.should.equal '1970-01-01T00:00:00Z'
