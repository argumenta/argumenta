Storage     = require '../lib/argumenta/storage'
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
