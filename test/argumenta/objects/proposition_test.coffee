should = require 'should'
Proposition = require '../../../lib/argumenta/objects/proposition'

describe 'Proposition', ->

  describe 'new()', ->
    it 'should create a new proposition instance', () ->
      prop = new Proposition 'the proposition text'
      prop.should.be.instanceof Proposition
      prop.text.should.equal 'the proposition text'

  describe 'objectRecord()', ->
    it 'should return the proposition object record', () ->
      prop = new Proposition 'the proposition text'
      prop.objectRecord().should.equal 'proposition the proposition text'

  describe 'sha1()', ->
    it 'should return the sha1 of the object record', () ->
      prop = new Proposition 'the proposition text'
      prop.sha1().should.equal '5d0f8723e110378563ba8d6e3cf336c0dcae4103'

  describe 'data()', ->
    it 'should return a plain object with proposition data', ->
      prop = new Proposition 'the proposition text'
      data = prop.data()
      data.should.eql {
        text: prop.text
        object_type: 'proposition'
        sha1: prop.sha1()
      }

  describe 'equals()', ->
    it 'should return true if propositions are equal', ->
      propositionA = new Proposition 'the proposition text'
      propositionB = new Proposition 'the proposition text'
      propositionA.equals(propositionB).should.equal true

    it 'should return false if propositions are not equal', ->
      propositionA = new Proposition 'the proposition text'
      propositionB = new Proposition 'different-text'
      propositionA.equals(propositionB).should.equal false

  describe 'validate()', ->
    it 'should return true if the text is valid', () ->
      p = new Proposition 'the proposition text'
      p.validate().should.equal true

    it 'should return false if text is blank', () ->
      p1 = new Proposition ''
      p2 = new Proposition '  '
      p1.validate().should.equal false
      p2.validate().should.equal false

    it 'should return false if text is too long', () ->
      text = ''
      text += 'abcde12345' for i in [1..30]   # 300 chars
      p = new Proposition text
      p.validate().should.equal false

  describe 'Proposition.parseRecord()', ->
    it 'should create a proposition instance from an object record', () ->
      record = 'proposition the proposition text'
      parsedProp = Proposition.parseRecord( record )
      parsedProp.should.be.instanceof Proposition
      parsedProp.text.should.equal 'the proposition text'
      parsedProp.sha1().should.equal '5d0f8723e110378563ba8d6e3cf336c0dcae4103'
      parsedProp.objectRecord().should.equal record
