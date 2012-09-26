Storage     = require '../lib/argumenta/storage'
User        = require '../lib/argumenta/user'
PublicUser  = require '../lib/argumenta/public_user'
Repo        = require '../lib/argumenta/repo'
Objects     = require '../lib/argumenta/objects'
fixtures    = require '../test/fixtures'
should      = require 'should'

{Argument, Proposition, Commit, Tag} = Objects

getStorage = (type) ->
  switch type
    when 'local'
      return new Storage
        storageType: 'local'
    when 'mongo'
      return new Storage
        storageType: 'mongo'
        storageUrl:  'mongodb://localhost:27017'

storageTypes = ['local']
for type in storageTypes
  storage = getStorage type
  describe "Storage with #{type} store", ->

    # Cleanup helper
    clearStorage = (done) ->
      storage.clearAll (err) ->
        should.not.exist err
        done()

    # WithUser Helper
    withUser = (callback) ->
      user = fixtures.uniqueUser()
      storage.addUser user, (err) ->
        should.not.exist err
        callback user

    # WithArgument Helper
    withArgument = (callback) ->
      withUser (user) ->
        argument = fixtures.validArgument()
        commit = new Commit 'argument', argument.sha1(), fixtures.validCommitter()
        storage.addCommit commit, (er1) ->
          storage.addArgument argument, (er2) ->
            [er1, er2].should.eql [1..2].map -> null
            callback user, commit, argument

    # WithArgumentRepo Helper
    withArgumentRepo = (callback) ->
      withArgument (user, commit, argument) ->
        reponame = argument.repo()
        storage.addRepo user.username, reponame, commit.sha1(), (err) ->
          should.not.exist err
          callback user, reponame, commit, argument

    afterEach clearStorage

    #### Users ####

    describe 'addUser( user, callback )', ->
      it 'should add a user successfully', (done) ->
        tester = fixtures.validUser()
        storage.addUser tester, (err) ->
          should.not.exist err
          done()

    describe 'getUser( username, callback )', ->
      it 'should get a stored user', (done) ->
        tester = fixtures.validUser()
        storage.addUser tester, (err) ->
          should.not.exist err
          storage.getUser tester.username, (err, user) ->
            should.not.exist err
            user.username.should.equal tester.username
            done()

    describe 'clearAll( callback )', ->
      it 'should delete all stored users', (done) ->
        tester = fixtures.validUser()
        storage.addUser tester, (err1) ->
          storage.clearAll (err2) ->
            storage.getUser tester.username, (err3, user)->
              should.ok err1 == err2 == null
              should.exist err3
              should.not.exist user
              done()

      it 'should delete all stored arguments & propositions', (done) ->
        argument = fixtures.validArgument()
        proposition = fixtures.validProposition()
        storage.addArgument argument, (er1) ->
          storage.addPropositions [proposition], (er2) ->
            storage.clearAll (er3) ->
              storage.getArguments [argument.sha1()], (er4, args) ->
                storage.getPropositions [proposition.sha1()], (er5, props) ->
                  [er1, er2, er3, er4, er5].should.eql ([1..5].map -> null)
                  args.length.should.equal 0
                  props.length.should.equal 0
                  done()

      it 'should delete all stored tags & commits', (done) ->
        tag = fixtures.validTag()
        commit = fixtures.validCommit()
        storage.addTag tag, (er1) ->
          storage.addCommit commit, (er2) ->
            storage.clearAll (er3) ->
              storage.getTags [tag.sha1()], (er4, tags) ->
                storage.getCommits [commit.sha1()], (er5, commits) ->
                  [er1, er2, er3, er4, er5].should.eql ([1..5].map -> null)
                  tags.length.should.equal 0
                  commits.length.should.equal 0
                  done()

    #### Repos ####

    describe 'addRepo( username, reponame, commit, callback )', ->
      it 'should store a repo for a valid user and commit', (done) ->
        user = fixtures.validUser()
        commit = fixtures.validCommit()
        reponame = fixtures.validRepoName()
        storage.addUser user, (er1) ->
          storage.addCommit commit, (er2) ->
            storage.addRepo user.username, reponame, commit.sha1(), (er3) ->
              [er1, er2, er3].should.eql [1..3].map -> null
              done()

      it 'should fail if no such user exists', (done) ->
        commit = fixtures.validCommit()
        reponame = fixtures.validRepoName()
        storage.addCommit commit, (er1) ->
          storage.addRepo 'nobody', reponame, commit.sha1(), (er2) ->
            should.not.exist er1
            er2.should.be.an.instanceOf Storage.NotFoundError
            done()

    describe 'getRepoHash( username, reponame, callback )', ->
      it 'should retrieve a commit hash for a stored repo', (done) ->
        user = fixtures.validUser()
        commit = fixtures.validCommit()
        reponame = fixtures.validRepoName()
        storage.addUser user, (er1) ->
          storage.addCommit commit, (er2) ->
            storage.addRepo user.username, reponame, commit.sha1(), (er3) ->
              storage.getRepoHash user.username, reponame, (er4, hash) ->
                [er1, er2, er3, er4].should.eql [1..4].map -> null
                hash.should.equal commit.sha1()
                done()

    describe 'getRepos( keys, callback )', ->
      it 'should retrieve repos by [username, reponame] keys', (done) ->
        withArgumentRepo (user1, repo1, commit1, argument1) ->
          withArgumentRepo (user2, repo2, commit2, argument2) ->
            key1 = [ user1.username, repo1 ]
            key2 = [ user2.username, repo2 ]
            keys = [ key1, key2 ]
            storage.getRepos keys, (err, repos) ->
              should.not.exist err
              repos.length.should.equal 2
              should.ok repos[0].equals new Repo( user1, repo1, commit1, argument1 )
              should.ok repos[1].equals new Repo( user2, repo2, commit2, argument2 )
              done()

    describe 'getRepoTarget( username, reponame, callback )', ->
      it 'should retrieve the commit and target object', (done) ->
        withArgumentRepo (user, reponame, commit, argument) ->
          storage.getRepoTarget user.username, reponame, (err, retrievedCommit, retrievedTarget) ->
            should.not.exist err
            retrievedCommit.equals( commit ).should.equal true
            retrievedTarget.equals( argument ).should.equal true
            done()

    #### Arguments ####

    describe 'addArgument( argument, callback )', ->
      it 'should store a valid argument', (done) ->
        argument = fixtures.validArgument()
        storage.addArgument argument, (err) ->
          should.not.exist err
          storage.getArguments [argument.sha1()], (err, args) ->
            should.not.exist err
            args.length.should.equal 1
            arg = args[0]
            arg.equals(argument).should.equal true
            done()

      it 'should store propositions along with argument', (done) ->
        withArgument (user, commit, argument) ->
          hashes = argument.propositions.map (p) -> p.sha1()
          storage.getPropositions hashes, (err, propositions) ->
            should.not.exist err
            propositions.should.exist
            propositions.length.should.equal hashes.length
            for prop, index in argument.propositions
              propositions[index].equals( prop ).should.equal true
            done()

      it 'should not store an invalid argument', (done) ->
        badArgument = fixtures.invalidArgument()
        storage.addArgument badArgument, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          done()

    describe 'getArgument( hash, callback )', ->
      it 'should retrieve a stored argument', (done) ->
        argument = fixtures.validArgument()
        storage.addArgument argument, (err) ->
          should.not.exist err
          storage.getArgument [argument.sha1()], (err, arg) ->
            should.not.exist err
            arg.equals(argument).should.equal true
            done()

    #### Commits ####

    describe 'addCommit( commit, callback )', ->
      it 'should store a valid commit', (done) ->
        commit = fixtures.validCommit()
        storage.addCommit commit, (err) ->
          should.not.exist err
          done()

      it 'should not store an invalid commit', (done) ->
        badCommit = fixtures.invalidCommit()
        storage.addCommit badCommit, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          done()

    describe 'getCommit( hash, callback )', ->
      it 'should retrieve a stored commit', (done) ->
        commit = fixtures.validCommit()
        storage.addCommit commit, (err) ->
          should.not.exist err
          storage.getCommit [commit.sha1()], (err, retrievedCommit) ->
            should.not.exist err
            retrievedCommit.equals(commit).should.equal true
            done()

    describe 'getCommits( hashes, callback )', ->
      it 'should retrieve a stored commit', (done) ->
        commitA = fixtures.validCommit()
        storage.addCommit commitA, (err) ->
          should.not.exist err
          storage.getCommits [commitA.sha1()], (err, commits) ->
            should.not.exist err
            commits.length.should.equal 1
            commitB = commits[0]
            commitB.equals( commitA ).should.equal true
            done()

    #### Tags ####

    describe 'addTag( tag, callback )', ->
      afterEach clearStorage

      it 'should store a valid tag successfully', (done) ->
        validTag = fixtures.validTag()
        storage.addTag validTag, (err) ->
          should.not.exist err
          storage.getTags [validTag.sha1()], (err, tags) ->
            should.not.exist err
            tags.length.should.equal 1
            tag = tags[0]
            should.ok tag.equals validTag
            done()

      it 'should not store an invalid tag', (done) ->
        badTag = fixtures.invalidTag()
        storage.addTag badTag, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          storage.getTags [badTag.sha1()], (err, retrievedTags) ->
            should.not.exist err
            retrievedTags.length.should.equal 0
            done()

    describe 'getTag( hash, callback )', ->
      it 'should retrieve a stored tag', (done) ->
        tag = fixtures.validTag()
        storage.addTag tag, (err) ->
          should.not.exist err
          storage.getTag [tag.sha1()], (err, retrievedTag) ->
            should.not.exist err
            retrievedTag.equals(tag).should.equal true
            done()

    describe 'getTags( hashes, callback )', ->
      it 'should retrieve stored support & dispute tags', (done) ->
        tagA = fixtures.validSupportTag()
        tagB = fixtures.validDisputeTag()
        storage.addTag tagA, (err) ->
          should.not.exist err
          storage.addTag tagB, (err) ->
            should.not.exist err
            storage.getTags [tagA.sha1(), tagB.sha1()], (err, tags) ->
              should.not.exist err
              tags.length.should.equal 2
              tag1 = tags[0]
              tag2 = tags[1]
              should.ok tag1.equals tagA
              should.ok tag2.equals tagB
              done()

      it 'should retrieve stored citation & commentary tags', (done) ->
        tagA = fixtures.validCitationTag()
        tagB = fixtures.validCommentaryTag()
        storage.addTag tagA, (err) ->
          should.not.exist err
          storage.addTag tagB, (err) ->
            should.not.exist err
            storage.getTags [tagA.sha1(), tagB.sha1()], (err, tags) ->
              should.not.exist err
              tags.length.should.equal 2
              tag1 = tags[0]
              tag2 = tags[1]
              should.ok tag1.equals tagA
              should.ok tag2.equals tagB
              done()

    #### Propositions ####

    describe 'addPropositions( propositions, callback )', ->
      it 'should add valid propositions successfully', (done) ->
        props = [
          fixtures.uniqueProposition()
          fixtures.uniqueProposition()
          fixtures.uniqueProposition()
        ]
        storage.addPropositions props, (err) ->
          should.not.exist err
          done()

      it 'should refuse to add anything but propositions', (done) ->
        props = [ 'Just a string' ]
        storage.addPropositions props, (err) ->
          should.exist err
          done()

      it 'should refuse to add invalid propositions', (done) ->
        props = [ fixtures.invalidProposition() ]
        storage.addPropositions props, (err) ->
          should.exist err
          done()

    describe 'getProposition( hash, callback )', ->
      it 'should retrieve a stored proposition', (done) ->
        proposition = fixtures.validProposition()
        storage.addPropositions [proposition], (err) ->
          should.not.exist err
          storage.getProposition [proposition.sha1()], (err, retrievedProposition) ->
            should.not.exist err
            retrievedProposition.equals(proposition).should.equal true
            done()

    describe 'getPropositions( hashes, callback )', ->
      it 'should get stored propositions', (done) ->
        propA = fixtures.uniqueProposition()
        propB = fixtures.uniqueProposition()
        props = [ propA, propB ]
        hashes = [ propA.sha1(), propB.sha1() ]
        storage.addPropositions props, (err) ->
          should.not.exist err
          storage.getPropositions hashes, (err, propositions) ->
            should.not.exist err
            propositions.length.should.equal 2
            should.ok propositions[0].equals propA
            should.ok propositions[1].equals propB
            done()
