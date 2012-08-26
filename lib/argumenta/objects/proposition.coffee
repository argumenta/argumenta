Errors = require './object_errors'
Utils  = require './object_utils'

#
# Propositions represent assertions as short strings of text.  
# Each may be used in arguments as a premise or conclusion.
#
class Proposition

  ### Constants ###

  # The character limit for proposition text.
  @MAX_PROPOSITION_LENGTH = 240

  Errors: @Errors = Errors

  ### Constructor ###

  # Create a Proposition instance for the given text.
  #
  #     text = 'The proposition text'
  #     proposition = new Proposition( text )
  #
  # @api public
  # @param [String] text The proposition text.
  constructor: (@text) ->

  ### Instance Methods ###

  # Get an object record representing this proposition.
  #
  # Proposition object records are strings of form:
  #
  #     proposition <text>
  #
  # @api public
  # @return [String] The object record.
  objectRecord: () ->
    return Proposition.objectRecord( @text )

  # Get the sha1 of this proposition's object record.
  #
  # The sha1 hash of the object record identifies the object:
  #
  #     proposition = new Proposition('The proposition text')
  #     sha1 = proposition.sha1()
  #
  #     assert.ok sha1 == '84a9386b1b5cba65cd32cb2558e5c4beba4053ae'
  #     assert.ok sha1 == Utils.SHA1( proposition.objectRecord() )
  #
  # @api public
  # @return [String] The sha1 hex value.
  sha1: () ->
    return Utils.SHA1 @objectRecord()

  # Checks for equality with another proposition.
  #
  #   isEqual = proposition1.equals( proposition2 )
  #
  # @api public
  # @param [Proposition] proposition The other proposition.
  # @return [Boolean] The equality result.
  equals: (proposition) ->
    return proposition instanceof Proposition and
      @objectRecord() == proposition.objectRecord()

  # Validates the proposition instance, returns true on success:
  #
  #     isValid = proposition.validate()
  #
  # Also sets properties `validationStatus` and `validationError`:
  #
  #     proposition.validationStatus # True on success
  #     proposition.validationError  # Null on success; otherwise the last error object.
  #
  # @api public
  # @see validationStatus, validationError
  # @return [Boolean] The validation status; true on success.
  validate: () ->
    try
      if @validateText()
        @validationStatus = true
        @validationError  = null
    catch err
      @validationStatus = false
      @validationError  = err
    finally
      return @validationStatus

  # Validates the instance's text field.
  #
  # @api private
  # @throws ValidationError
  # @return [Boolean] True only on success.
  validateText: () ->
    Proposition.validateText @text

  ### Static Methods ###

  # Parse a proposition object record, creating a new Proposition instance.
  #
  #     objectRecord = 'proposition The proposition text'
  #     proposition = Proposition.parseRecord( objectRecord )
  #
  # @api public
  # @param [String] objectRecord The record to parse.
  # @return [Proposition] A new proposition instance.
  @parseRecord: (objectRecord) ->
    matches = objectRecord.match /^proposition (.+)/
    if matches
      text = matches[1]
      return new Proposition text
    else
      return null

  # Return an object record for the given proposition text.
  #
  #     text = 'The proposition text'
  #     record = Proposition.objectRecord( text )
  #     record.should.equal 'proposition The proposition text'
  #
  # @api private
  # @param [String] text The proposition text.
  # @return [String] The object record.
  @objectRecord: (text) ->
    return 'proposition ' + text

  # Validates a proposition text field.
  #
  # @api private
  # @throws ValidationError
  # @param [String] text The proposition text.
  # @return [Boolean] True only on success.
  @validateText: (text) ->
    unless text.match /\S+/
      throw new Errors.ObjectValidation "Propositions must not be blank."
    unless text.length <= @MAX_PROPOSITION_LENGTH
      throw new Errors.ObjectValidation "Propositions must be #{@MAX_PROPOSITION_LENGTH} characters or less."
    return true

module.exports = Proposition
