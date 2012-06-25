crypto = require 'crypto'

class Proposition

  # Constructor
  # -----------

  # Create a `Proposition` instance for the given `text`.
  #
  # Param _String_ `text`
  constructor: (@text) ->

  # Instance methods
  # ----------------

  # Get an object record representing this proposition.  
  # Proposition object records have the form:
  #
  #     proposition <text>
  #
  # The hash of the object record identifies the object:
  #
  #     crypto = require('crypto')
  #     shasum = crypto.createHash('sha1')
  #
  #     prop = new Proposition('The proposition text')
  #     obj_sha1 = shasum.update( prop.objectRecord(), 'utf8' ).digest('hex')
  #
  #     prop.sha1() == obj_sha1
  #
  # Returns _String_ `objectRecord`
  objectRecord: () ->
    return Proposition.objectRecord( @text )

  # Get the `sha1` of this proposition's object record.  
  #
  # See `objectRecord()`  
  # Returns _String_ `sha1` The sha1 hex value.
  sha1: () ->
    shasum = crypto.createHash 'sha1'
    return shasum.update(@objectRecord(), 'utf8').digest('hex')

  # Static Methods
  # --------------

  # Get a proposition object record for the given `text`.  
  # No instance is created.
  #
  # Param _String_ `text`  
  # Returns _String_ `objectRecord`
  @objectRecord: (text) ->
    return 'proposition ' + text


  # Parse a proposition object record, creating a new instance.  
  #
  # Param _String_ `objectRecord`  
  # Returns _Proposition_ `parsedProposition`
  @parseRecord: (objectRecord) ->
    matches = objectRecord.match /^proposition (.+)/
    if matches
      text = matches[1]
      return new Proposition text
    else
      return null

module.exports = Proposition
