should = require 'should'
Proposition = require '../../lib/argumenta/objects/proposition'

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

  describe 'Proposition.parseRecord()', ->
    it 'should create a proposition instance from an object record', () ->
      record = 'proposition the proposition text'
      parsedProp = Proposition.parseRecord( record )
      parsedProp.should.be.instanceof Proposition
      parsedProp.text.should.equal 'the proposition text'
      parsedProp.sha1().should.equal '5d0f8723e110378563ba8d6e3cf336c0dcae4103'
      parsedProp.objectRecord().should.equal record
