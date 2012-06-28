crypto = require 'crypto'

class Proposition

  # Constructor
  # -----------

  # Create a Proposition instance for the given text.
  #
  #     text = 'The proposition text'
  #     proposition = new Proposition( text )
  #
  # @param [String] text The proposition text.
  constructor: (@text) ->

  # Instance Methods
  # ----------------

  # Get an object record representing this proposition.
  #
  # Proposition object records are strings of form:
  #
  #     proposition <text>
  #
  # @return [String] The object record.
  objectRecord: () ->
    return Proposition.objectRecord( @text )

  # Get the sha1 of this proposition's object record.
  #
  # The sha1 hash of the object record identifies the object:
  #
  #     proposition = new Proposition('The proposition text')
  #
  #     shasum  = require('crypto').createHash('sha1')
  #     objSha1 = shasum.update( proposition.objectRecord(), 'utf8' ).digest('hex')
  #
  #     assert.ok objSha1 ==  proposition.sha1()
  #     assert.ok objSha1 == '84a9386b1b5cba65cd32cb2558e5c4beba4053ae'
  #
  # @return [String] The sha1 hex value.
  sha1: () ->
    shasum = crypto.createHash 'sha1'
    return shasum.update(@objectRecord(), 'utf8').digest('hex')

  # Static Methods
  # --------------

  # Return an object record for the given proposition text.
  #
  #     text = 'The proposition text'
  #     record = Proposition.objectRecord( text )
  #     record.should.equal 'proposition The proposition text'
  #
  # @param [String] text The proposition text.
  # @return [String] The object record.
  @objectRecord: (text) ->
    return 'proposition ' + text

  # Parse a proposition object record, creating a new Proposition instance.
  #
  #     objectRecord = 'proposition The proposition text'
  #     proposition = Proposition.parseRecord( objectRecord )
  #
  # @param [String] objectRecord The record to parse.
  # @return [Proposition] A new proposition instance.
  @parseRecord: (objectRecord) ->
    matches = objectRecord.match /^proposition (.+)/
    if matches
      text = matches[1]
      return new Proposition text
    else
      return null

module.exports = Proposition
