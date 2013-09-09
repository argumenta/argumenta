config      = require '../config'
Storage     = require '../lib/argumenta/storage'
LocalStore  = require '../lib/argumenta/storage/local_store'
User        = require '../lib/argumenta/user'
PublicUser  = require '../lib/argumenta/public_user'
Repo        = require '../lib/argumenta/repo'
Objects     = require '../lib/argumenta/objects'
fixtures    = require '../test/fixtures'
_           = require 'underscore'
should      = require 'should'

{Argument, Proposition, Commit, Tag} = Objects

getStorage = (type, config) ->
  switch type
    when 'local'
      return new Storage
        storageType: 'local'
    when 'postgres'
      return new Storage
        storageType: 'postgres'
        storageUrl:   config.postgresUrl

describeAllTests = () ->
  storageTypes = ['local', 'postgres']

  for type in storageTypes
    storage = getStorage type, config
    describeStorageTests storage, type

describeStorageTests = (storage, type) ->

  describe "Storage with #{type} store", ->

    # Cleanup helper
    clearStorage = (done) ->
      storage.clearAll null, (err) ->
        should.not.exist err
        done()

    # Cleanup Quick helper
    clearStorageQuick = (done) ->
      storage.clearAll {quick: true}, (err) ->
        should.not.exist err
        done()

    # WithProposition Helper
    withProposition = (callback) ->
      proposition = fixtures.uniqueProposition()
      storage.addPropositions [proposition], (err) ->
        should.not.exist err
        storage.getProposition proposition.sha1(), (err, retrievedProposition) ->
          should.not.exist err
          callback retrievedProposition

    # WithUser Helper
    withUser = (callback) ->
      user = fixtures.uniqueUser()
      storage.addUser user, (err) ->
        should.not.exist err
        callback user

    # WithCommit Helper
    withCommit = (callback) ->
      withArgument (user, commit, arg) ->
        return callback user, arg, commit

    # WithArgument Helper
    withArgument = (argument, callback) ->
      if arguments.length is 1
        callback = arguments[0]
        argument = fixtures.uniqueArgument()
      withUser (user) ->
        commit = new Commit 'argument', argument.sha1(), user.username
        storage.addArgument argument, (er1) ->
          storage.addCommit commit, (er2) ->
            [er1, er2].should.eql [1..2].map -> null
            callback user, commit, argument

    # WithArgumentRepo Helper
    withArgumentRepo = (callback) ->
      withArgument (user, commit, argument) ->
        reponame = argument.repo()
        storage.addRepo user.username, reponame, commit.sha1(), (err) ->
          should.not.exist err
          callback user, reponame, commit, argument

    # With Citation Tag
    withCitationTag = (callback) ->
      withArgument (user, argCommit, argument) ->
        prop = argument.propositions[0]
        text = fixtures.validCitationText()
        tag = new Tag 'citation', 'proposition', prop.sha1(), text
        tagCommit = new Commit 'tag', tag.sha1(), user.username
        storage.addTag tag, (err) ->
          should.not.exist err
          storage.addCommit tagCommit, (err) ->
            should.not.exist err
            callback user, prop, tagCommit, tag

    # With Commentary Tag
    withCommentaryTag = (callback) ->
      withArgument (user, argCommit, argument) ->
        text = fixtures.validCommentaryText()
        tag = new Tag 'commentary', 'argument', argument.sha1(), text
        tagCommit = new Commit 'tag', tag.sha1(), user.username
        storage.addTag tag, (err) ->
          should.not.exist err
          storage.addCommit tagCommit, (err) ->
            should.not.exist err
            callback user, argument, tagCommit, tag

    # With Support Tag
    withSupportTag = (callback) ->
      withArgument (user, argCommit, argument) ->
        target = prop1 = argument.propositions[0]
        source = prop2 = argument.propositions[1]
        tag = new Tag 'support', 'proposition', prop1.sha1(), 'proposition', prop2.sha1()
        tagCommit = new Commit 'tag', tag.sha1(), user.username
        storage.addTag tag, (err) ->
          should.not.exist err
          storage.addCommit tagCommit, (err) ->
            should.not.exist err
            callback user, target, source, tagCommit, tag

    # With Dispute Tag
    withDisputeTag = (callback) ->
      withArgument (user, argCommit, argument) ->
        target = prop1 = argument.propositions[0]
        source = prop2 = argument.propositions[1]
        tag = new Tag 'dispute', 'proposition', prop1.sha1(), 'proposition', prop2.sha1()
        tagCommit = new Commit 'tag', tag.sha1(), user.username
        storage.addTag tag, (err) ->
          should.not.exist err
          storage.addCommit tagCommit, (err) ->
            should.not.exist err
            callback user, target, source, tagCommit, tag

    before clearStorage
    afterEach clearStorageQuick

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
            user.joinDate.should.equal tester.joinDate
            user.gravatarId.should.match /^[0-9,a-f]{32}$/
            done()

    describe 'getUsers( usernames, callback )', ->
      it 'should get stored users', (done) ->
        withUser (user1) ->
          withUser (user2) ->
            pubUser1 = new PublicUser( user1 )
            pubUser2 = new PublicUser( user2 )
            usernames = [ user1.username, user2.username ]
            storage.getUsers usernames, (err, users) ->
              should.not.exist err
              users.length.should.equal 2
              should.ok _.some users, (u) -> u.equals pubUser1
              should.ok _.some users, (u) -> u.equals pubUser2
              done()

    describe 'getUsersWithMetadata( usernames, callback )', ->
      it 'should get stored users with metadata', (done) ->
        withArgumentRepo (user1, repo1, commit1, argument1) ->
          withUser (user2) ->
            usernames = [ user1.username, user2.username ]
            storage.getUsersWithMetadata usernames, (err, users) ->
              should.not.exist err
              users.length.should.equal 2
              should.ok _.some users, (u) -> u.metadata.repos_count == 1
              should.ok _.some users, (u) -> u.metadata.repos_count == 0
              done()

    describe 'clearAll( opts, callback )', ->
      it 'should delete all stored users', (done) ->
        tester = fixtures.validUser()
        storage.addUser tester, (err1) ->
          storage.clearAll {quick: true}, (err2) ->
            storage.getUser tester.username, (err3, user)->
              should.ok err1 == err2 == null
              should.exist err3
              should.not.exist user
              done()

      it 'should delete all stored arguments & propositions', (done) ->
        withArgument (user, commit, argument) ->
          storage.clearAll {quick: true}, (er1) ->
            storage.getArguments [argument.sha1()], (er2, args) ->
              prop = argument.propositions[0]
              storage.getPropositions [prop.sha1()], (er3, props) ->
                [er1, er2, er3].should.eql ([1..3].map -> null)
                args.length.should.equal 0
                props.length.should.equal 0
                done()

      it 'should delete all stored tags & commits', (done) ->
        withSupportTag (user, target, source, commit, tag) ->
          storage.clearAll {quick: true}, (er1) ->
            storage.getTags [tag.sha1()], (er2, tags) ->
              storage.getCommits [commit.sha1()], (er3, commits) ->
                [er1, er2, er3].should.eql ([1..3].map -> null)
                tags.length.should.equal 0
                commits.length.should.equal 0
                done()

    #### Repos ####

    describe 'addRepo( username, reponame, commit, callback )', ->
      it 'should store a repo for a valid user and commit', (done) ->
        withArgument (user, commit, argument) ->
          reponame = Argument.slugify( argument.title )
          storage.addRepo user.username, reponame, commit.sha1(), (err) ->
            should.not.exist err
            done()

      it 'should fail if no such user exists', (done) ->
        withArgument (user, commit, argument) ->
          reponame = Argument.slugify( argument.title )
          storage.addRepo 'nobody', reponame, commit.sha1(), (err) ->
            should.exist err
            err.should.be.an.instanceOf Storage.NotFoundError
            done()

    describe 'getRepoHash( username, reponame, callback )', ->
      it 'should retrieve a commit hash for a stored repo', (done) ->
        withArgumentRepo (user, repo, commit, argument) ->
          reponame = Argument.slugify( argument.title )
          storage.getRepoHash user.username, reponame, (err, hash) ->
            should.not.exist err
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
          reponame = Argument.slugify( argument.title )
          storage.getRepoTarget user.username, reponame, (err, retrievedCommit, retrievedTarget) ->
            should.not.exist err
            retrievedCommit.equals( commit ).should.equal true
            retrievedTarget.equals( argument ).should.equal true
            done()

    describe 'deleteRepo( username, reponame, callback )', ->
      it 'should delete a given repo', (done) ->
        withArgumentRepo (user, reponame, commit, argument) ->
          username = user.username
          key = [username, reponame]
          storage.deleteRepo username, reponame, (err) ->
            should.not.exist err
            storage.getRepos [key], (err, repos) ->
              should.not.exist err
              repos.length.should.equal 0
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

    describe 'getArguments( hashes, callback )', ->
      it 'should retrieve stored arguments by hashes', (done) ->
        withArgument (user1, commit1, argument1) ->
          withArgument (user2, commit2, argument2) ->
            hashes = [argument1.sha1(), argument2.sha1()]
            storage.getArguments hashes, (err, args) ->
              should.not.exist err
              args.length.should.equal 2
              args[0].equals(argument1).should.equal true
              args[1].equals(argument2).should.equal true
              done()

    describe 'getArgumentsWithMetadata( hashes, callback )', ->
      it 'should retrieve stored arguments with propositions metadata', (done) ->
        withArgument (user1, commit1, argument1) ->
          withArgument (user2, commit2, argument2) ->
            hashes = [argument1.sha1(), argument2.sha1()]
            storage.getArgumentsWithMetadata hashes, (err, args) ->
              should.not.exist err
              args.length.should.equal 2
              should.exist args[0].propositions[0].metadata
              done()

    #### Commits ####

    describe 'addCommit( commit, callback )', ->
      it 'should store a valid commit', (done) ->
        withArgument (user, commit1, arg) ->
          commit = new Commit 'argument', arg.sha1(), user.username
          storage.addCommit commit, (err) ->
            should.not.exist err
            done()

      it 'should not store an invalid commit', (done) ->
        badCommit = fixtures.invalidCommit()
        storage.addCommit badCommit, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          done()

      it 'should store a commit with host', (done) ->
        withArgument (user, commit1, arg) ->
          commit = new Commit
            targetType: 'argument'
            targetSha1: arg.sha1()
            committer:  user.username
            host:       'testing.argumenta.io'
          storage.addCommit commit, (err) ->
            should.not.exist err
            done()

    describe 'getCommit( hash, callback )', ->
      it 'should retrieve a stored commit', (done) ->
        withCommit (user, arg, commit) ->
          storage.getCommit commit.sha1(), (err, retrievedCommit) ->
            should.not.exist err
            retrievedCommit.equals(commit).should.equal true
            done()

      it 'should retrieve a commit with host', (done) ->
        withArgument (user, commit1, arg) ->
          commit = new Commit
            targetType: 'argument'
            targetSha1: arg.sha1()
            committer:  user.username
            host:       'testing.argumenta.io'
          storage.addCommit commit, (err) ->
            should.not.exist err
            storage.getCommit commit.sha1(), (err, retrievedCommit) ->
              retrievedCommit.equals(commit).should.equal true
              done()

    describe 'getCommits( hashes, callback )', ->
      it 'should retrieve a stored commit', (done) ->
        withCommit (user1, arg1, commit1) ->
          withCommit (user2, arg2, commit2) ->
            storage.getCommits [commit1.sha1(), commit2.sha1()], (err, commits) ->
              should.not.exist err
              commits.length.should.equal 2
              commit1.equals(commits[0]).should.equal true
              commit2.equals(commits[1]).should.equal true
              done()

    describe 'getCommitsFor( hashes, callback )', ->
      it 'should retrieve stored commits by target hash', (done) ->
        withArgument (user, commit1, argument1) ->
          withArgument (user, commit2, argument2) ->
            targetHashes = [argument1.sha1(), argument2.sha1()]
            storage.getCommitsFor targetHashes, (err, commits) ->
              should.not.exist err
              commits.length.should.equal 2
              should.ok commit1.equals commits[0]
              should.ok commit2.equals commits[1]
              done()

    #### Tags ####

    describe 'addTag( tag, callback )', ->
      afterEach clearStorageQuick

      it 'should store a valid tag successfully', (done) ->
        withArgument (user1, commit1, argument1) ->
          withArgument (user2, commit2, argument2) ->
            tag = new Tag 'support',
              'proposition', argument1.propositions[0].sha1(),
              'argument', argument2.sha1()
            storage.addTag tag, (err) ->
              should.not.exist err
              storage.getTags [tag.sha1()], (err, tags) ->
                should.not.exist err
                tags.length.should.equal 1
                tags[0].equals(tag).should.equal true
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
        withSupportTag (user, target, source, commit, tag) ->
          storage.getTag tag.sha1(), (err, retrievedTag) ->
            should.not.exist err
            retrievedTag.equals(tag).should.equal true
            done()

    describe 'getTags( hashes, callback )', ->
      it 'should retrieve stored support & dispute tags', (done) ->
        withSupportTag (user1, target1, source1, commit1, tag1) ->
          withDisputeTag (user2, target2, source2, commit2, tag2) ->
            storage.getTags [tag1.sha1(), tag2.sha1()], (err, tags) ->
              should.not.exist err
              tags.length.should.equal 2
              should.ok tags[0].equals tag1
              should.ok tags[1].equals tag2
              done()

      it 'should retrieve stored citation & commentary tags', (done) ->
        withCitationTag (user1, target1, commit1, tag1) ->
          withCommentaryTag (user2, target2, commit2, tag2) ->
            storage.getTags [tag1.sha1(), tag2.sha1()], (err, tags) ->
              should.not.exist err
              tags.length.should.equal 2
              should.ok tags[0].equals tag1
              should.ok tags[1].equals tag2
              done()

    describe 'getTagsFor( hashes, callback )', ->
      it 'should retrieve stored tags by target hash', (done) ->
        withCitationTag (user1, proposition1, tag1Commit, tag1) ->
          withCitationTag (user2, proposition2, tag2Commit, tag2) ->
            targetHashes = [proposition1.sha1(), proposition2.sha1()]
            storage.getTagsFor targetHashes, (err, tags) ->
              should.not.exist err
              tags.length.should.equal 2
              should.ok _.some tags, (t) -> t.equals tag1
              should.ok _.some tags, (t) -> t.equals tag2
              done()

    describe 'getTagsPlusSources( targetHashes, callback )', ->
      it 'should retrieve citation tags, sources, and commits', (done) ->
        withCitationTag (user1, proposition1, tag1Commit, tag1) ->
          withCitationTag (user2, proposition2, tag2Commit, tag2) ->
            targetHashes = [proposition1.sha1(), proposition2.sha1()]
            storage.getTagsPlusSources targetHashes, (err, tags, sources, commits) ->
              tags.length.should.equal 2
              sources.length.should.equal 0
              commits.length.should.equal 2
              should.ok _.some tags, (t) -> t.equals tag1
              should.ok _.some tags, (t) -> t.equals tag2
              should.ok _.some commits, (c) -> c.equals tag1Commit
              should.ok _.some commits, (c) -> c.equals tag2Commit
              done()

      it 'should retrieve support tags, sources, and commits', (done) ->
        withSupportTag (user, target1, source1, tag1Commit, tag1) ->
          withSupportTag (user, target2, source2, tag2Commit, tag2) ->
            targetHashes = [target1.sha1(), target2.sha1()]
            storage.getTagsPlusSources targetHashes, (err, tags, sources, commits) ->
              tags.length.should.equal 2
              should.ok tag1.equals tags[0]
              should.ok tag2.equals tags[1]
              should.ok source1.equals sources[0]
              should.ok source2.equals sources[1]
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

          hashes = props.map (p) -> p.sha1()
          storage.getPropositions hashes, (err, storedProps) ->
            should.not.exist err
            storedProps.length.should.equal props.length
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
          storage.getProposition proposition.sha1(), (err, retrievedProposition) ->
            should.not.exist err
            retrievedProposition.equals(proposition).should.equal true
            done()

      it 'should retrieve propositions modifiable without side effects', (done) ->
        withProposition (prop1) ->
          hash = prop1.sha1()
          text = prop1.text
          prop1.text = 'something different'
          storage.getProposition hash, (err, prop2) ->
            should.not.exist err
            prop2.text.should.equal text
            prop2.sha1().should.equal hash
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

    describe 'getPropositionsMetadata( hashes, callback )', ->
      it 'should get propositions metadata', (done) ->
        withCitationTag (user1, prop1, tag1Commit, tag1) ->
          withSupportTag (user2, prop2, source, tag2Commit, tag2) ->
            hashes = [prop1.sha1(), prop2.sha1()]
            storage.getPropositionsMetadata hashes, (err, metadata) ->
              metadata.length.should.equal 2
              m1 = metadata[0]
              m2 = metadata[1]
              m1.sha1.should.equal prop1.sha1()
              m2.sha1.should.equal prop2.sha1()
              m1.tag_counts.citation.should.equal 1
              m2.tag_counts.support.should.equal 1
              m1.tag_sha1s.citation[0].should.equal tag1.sha1()
              m2.tag_sha1s.support[0].should.equal tag2.sha1()
              done()

    describe 'getPropositionsWithMetadata( hashes, callback )', ->
      it 'should get propositions along with metadata', (done) ->
        withCitationTag (user1, prop1, tag1Commit, tag1) ->
          withSupportTag (user2, prop2, source, tag2Commit, tag2) ->
            hashes = [prop1.sha1(), prop2.sha1()]
            storage.getPropositionsWithMetadata hashes, (err, propositions) ->
              propositions.length.should.equal 2
              p1 = propositions[0]
              p2 = propositions[1]
              should.ok p1.equals prop1
              should.ok p2.equals prop2
              p1.metadata.tag_counts.citation.should.equal 1
              p2.metadata.tag_counts.support.should.equal 1
              p1.metadata.tag_sha1s.citation[0].should.equal tag1.sha1()
              p2.metadata.tag_sha1s.support[0].should.equal tag2.sha1()
              done()

    describe 'search( query, options, callback )', ->
      it 'should find an argument by title', (done) ->
        withArgument (user, commit, argument) ->
          query = argument.title
          options = {}
          storage.search query, options, (err, results) ->
            should.not.exist err
            results.arguments.length.should.equal 1
            should.ok results.arguments[0].equals argument
            done()

      it 'should find an argument by full text', (done) ->
        withArgument (user, commit, argument) ->
          query = argument.title + ' ' + argument.premises[0].text
          options = {}
          storage.search query, options, (err, results) ->
            should.not.exist err
            results.arguments.length.should.equal 1
            should.ok results.arguments[0].equals argument
            done()

      it 'should find a user by username', (done) ->
        withUser (user) ->
          pubUser = new PublicUser( user )
          query = user.username
          options = {}
          storage.search query, options, (err, results) ->
            should.not.exist err
            results.users.length.should.equal 1
            should.ok results.users[0].equals pubUser
            done()

      it 'should rank results by frequency', (done) ->
        if storage.store instanceof LocalStore
          return done()
        arg1 = fixtures.uniqueArgument()
        arg2 = fixtures.uniqueArgument()
        arg1.title = 'spam'
        arg2.title = 'spam spam eggs and spam'
        withArgument arg1, (user1, commit1, argument1) ->
          withArgument arg2, (user1, commit2, argument2) ->
            query = 'spam'
            storage.search query, {}, (err, results) ->
              should.ok results.arguments[0].equals arg2
              should.ok results.arguments[1].equals arg1
              done()

describeAllTests()
