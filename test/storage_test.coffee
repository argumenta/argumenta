Storage     = require '../lib/argumenta/storage'
User        = require '../lib/argumenta/user'
Argument    = require '../lib/argumenta/objects/argument'
Proposition = require '../lib/argumenta/objects/proposition'
Commit      = require '../lib/argumenta/objects/commit'
should      = require 'should'

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

    #### Users ####

    username = 'tester'
    password_hash = '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
    email = 'tester@xyz.com'

    describe 'addUser( user, callback )', ->
      it 'should add a user successfully', (done) ->
        tester = new User
          username: username
          password_hash: password_hash
          email: email
        storage.addUser tester, (err) ->
          should.not.exist err
          done()

    describe 'getUser( username, callback )', ->
      it 'should get a stored user', (done) ->
        storage.getUser 'tester', (err, user) ->
          should.not.exist err
          user.username.should.equal 'tester'
          done()

    describe 'clearAll( callback )', ->
      it 'should delete all stored entities', (done) ->
        storage.clearAll (err) ->
          should.not.exist err
          # Check that user is really gone
          storage.getUser 'tester', (err, user)->
            should.exist err
            should.not.exist user
            done()

    #### Arguments ####

    title = 'The Argument Title'
    premises = [ 'The first premise.', 'The second premise.' ]
    conclusion = 'The conclusion.'

    describe 'addArgument( argument, callback )', ->
      it 'should store a valid argument', (done) ->
        argument = new Argument title, premises, conclusion
        storage.addArgument argument, (err) ->
          should.not.exist err
          storage.getArguments [argument.sha1()], (err, args) ->
            should.not.exist err
            args.length.should.equal 1
            arg = args[0]
            arg.title.should.equal 'The Argument Title'
            arg.sha1().should.equal '7077e1ce31bc8e9d2a88479aa2d159f2f9de4856'
            arg.should.eql argument
            done()

      it 'should not store an invalid argument', (done) ->
        badArgument = new Argument '', [''], ''
        storage.addArgument badArgument, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          done()

    #### Commits ####

    targetType = 'argument'
    targetSha1 = '39cb3925a38f954cf4ca12985f5f948177f6da5e'
    committer = 'tester'
    commitDate = '1970-01-01T00:00:00Z'
    parentSha1 = '0123456789abcdef000000000000000000000000'

    describe 'addCommit( commit, callback )', ->
      it 'should store a valid commit', (done) ->
        commit = new Commit targetType, targetSha1, committer, commitDate, [parentSha1]
        storage.addCommit commit, (err) ->
          should.not.exist err
          done()

      it 'should not store an invalid commit', (done) ->
        badCommit = new Commit '', '', '', '', ''
        storage.addCommit badCommit, (err) ->
          should.exist err
          err.should.be.an.instanceOf Storage.InputError
          done()

    describe 'getCommits( hashes, callback )', ->
      it 'should retrieve a stored commit', (done) ->
        commitA = new Commit targetType, targetSha1, committer, commitDate, [parentSha1]
        storage.addCommit commitA, (err) ->
          should.not.exist err
          storage.getCommits [commitA.sha1()], (err, commits) ->
            should.not.exist err
            commits.length.should.equal 1
            commitB = commits[0]
            commitB.should.be.an.instanceOf Commit
            commitB.objectRecord().should.equal commitA.objectRecord()
            commitB.sha1().should.equal 'c757c63182236eaddf12942ecd284bf0d678c040'
            commitB.validate().should.equal true
            done()

    #### Propositions ####

    describe 'addPropositions( propositions, callback )', ->
      it 'should add valid propositions successfully', (done) ->
        props = [
          new Proposition('first proposition')
          new Proposition('second proposition')
          new Proposition('third proposition')
        ]
        storage.addPropositions props, (err) ->
          should.not.exist err
          done()

      it 'should refuse to add anything but propositions', (done) ->
        props = [
          "Just a string"
        ]
        storage.addPropositions props, (err) ->
          should.exist err
          done()

      it 'should refuse to add invalid propositions', (done) ->
        props = [
          new Proposition """
            This text is too long for a proposition. This text is too long for a proposition.
            This text is too long for a proposition. This text is too long for a proposition.
            This text is too long for a proposition. This text is too long for a proposition.
            """
        ]
        storage.addPropositions props, (err) ->
          should.exist err
          done()

    describe 'getPropositions( hashes, callback )', ->
      it 'should get stored propositions', (done) ->
        hashes = [
          '4d2c438035e176dbfa4fe395bdba128a11dff8f8'
          'd7439bc3b3fab3712280da6bdf3a3940f23a9c1f'
          '16b0169ed8d54062ca81f26bc441f16d32b3be00'
        ]
        storage.getPropositions hashes, (err, propositions) ->
          should.not.exist err
          propositions.length.should.equal 3
          propositions[0].text.should.equal 'first proposition'
          propositions[1].text.should.equal 'second proposition'
          propositions[2].text.should.equal 'third proposition'
          done()
