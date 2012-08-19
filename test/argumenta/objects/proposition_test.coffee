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