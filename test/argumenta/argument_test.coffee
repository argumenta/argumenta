should      = require 'should'
Argument    = require '../../lib/argumenta/objects/argument'
Proposition = require '../../lib/argumenta/objects/proposition'

describe 'Argument', ->

  title = 'The Argument Title'
  premises = [
    'The first premise.'
    'The second premise.'
  ]
  conclusion = 'The conclusion.'

  describe 'new Argument( title, premises, conclusion )', ->

    it 'should create a new instance', ->
      argument = new Argument title, premises, conclusion
      argument.should.be.an.instanceOf Argument
      argument.propositions.length.should.equal 3

      argument.title.should.equal 'The Argument Title'

      argument.premises.length.should.equal 2
      argument.premises[0].should.be.an.instanceOf Proposition
      argument.premises[0].text.should.equal 'The first premise.'

      argument.conclusion.should.be.an.instanceOf Proposition
      argument.conclusion.text.should.equal 'The conclusion.'

  describe 'children()', ->
    it 'should return an array with premises and conclusion', ->
      argument = new Argument title, premises, conclusion
      argument.children().length.should.equal 3
      for child in argument.children()
        child.should.be.an.instanceOf Proposition

  describe 'objectRecord()', ->
    it 'should return the argument object record', ->
      argument = new Argument title, premises, conclusion
      record = argument.objectRecord()
      record.should.equal """
        argument

        title The Argument Title
        premise d7574671f9327761109829761d97d7001b60cd43
        premise 503db2aa0a6d31e73f66c3efd8e15f92ee7d11be
        conclusion 3940b2a6a3d5778297f0e37a06109f9d3dcffe6d
        """

  describe 'sha1()', ->
    it 'should return the sha1 sum of the object record', ->
      argument = new Argument title, premises, conclusion
      sha1 = argument.sha1()
      sha1.should.equal '39cb3925a38f954cf4ca12985f5f948177f6da5e'

  describe 'validate()', ->

    it 'should return true if all components are valid', ->
      argument = new Argument title, premises, conclusion
      argument.validate().should.equal true

    it 'should return false if missing title', ->
      argument = new Argument '', premises, conclusion
      argument.validate().should.equal false

    it 'should return false if missing premises', ->
      argument = new Argument title, [ '' ], conclusion
      argument.validate().should.equal false

    it 'should return false if missing conclusion', ->
      argument = new Argument title, premises, ''
      argument.validate().should.equal false
