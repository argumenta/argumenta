Storage     = require '../lib/argumenta/storage'
User        = require '../lib/argumenta/user'
Proposition = require '../lib/argumenta/objects/proposition'
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

describe 'Storage', ->

  storageTypes = ['local']
  for type in storageTypes

    describe 'with storageType: ' + type, ->
      storage = getStorage type

      tester = new User
        username: 'tester'
        password_hash: '$2a$10$EdsQm10l4VTDkr4eLvH09.aXtug.QHDxhNnVHY3Jm.RaG6s5msek2'
        email:    'tester@xyz.com'

      describe 'addUser()', ->
        it 'should add a user successfully', (done) ->
          storage.addUser tester, (err) ->
            should.not.exist err
            done()

      describe 'getUserByName()', ->
        it 'should get a stored user', (done) ->
          storage.getUserByName 'tester', (err, user) ->
            should.not.exist err
            user.username.should.equal 'tester'
            done()

      describe 'clearAll()', ->
        it 'should delete all stored entities', (done) ->
          storage.clearAll (err) ->
            should.not.exist err
            # Check that user is really gone
            storage.getUserByName 'tester', (err, user)->
              should.exist err
              should.not.exist user
              done()

      describe 'storage.addPropositions()', ->

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

      describe 'storage.getPropositions()', ->

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
