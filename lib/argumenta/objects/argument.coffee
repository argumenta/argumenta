crypto      = require 'crypto'
_           = require 'underscore'
Proposition = require './proposition'
Errors      = require './object_errors'

#
# Arguments represent a series of premises leading to a conclusion.  
# Each premise or conclusion is represented by a proposition.
#
# @api public
# @property [String]             title The title text.
# @property [Array<Proposition>] premises The premise objects.
# @property [Proposition]        conclusion The conclusion object.
#
class Argument

  ### Constants ###

  # The character limit for argument titles.
  @MAX_TITLE_LENGTH: 160

  # Static and instance refs to all object errors.
  Errors: @Errors = Errors

  ### Constructor ###

  # Inits an Argument instance.
  #
  #     title = 'The Argument Title'
  #     premises = [
  #       'The first premise.'
  #       'The second premise.'
  #     ]
  #     conclusion = 'The conclusion.'
  #
  #     arg = new Argument( title, premises, conclusion )
  #
  # @api public
  # @param [String]        title The title text.
  # @param [Array<String>] premises The premise texts.
  # @param [String]        conclusion The conclusion text.
  constructor: (title, premises, conclusion) ->
    @title = Argument.sanitizeTitle title
    @premises = []
    @premises.push new Proposition p for p in premises
    @conclusion = new Proposition conclusion
    @propositions = [].concat @premises, @conclusion

  ### Accessors ###

  # Gets all child objects (premises and conclusion).
  #
  # @api public
  # @return [Array<Proposition>] The premise and conclusion propositions.
  children: () ->
    return @propositions

  # Gets the argument's object record.
  #
  # Example usage:
  #
  #     record = argument.objectRecord()
  #
  # An example record, with two premises and a conclusion:
  #
  #     argument
  #
  #     title The Argument Title
  #     premise d7574671f9327761109829761d97d7001b60cd43
  #     premise 503db2aa0a6d31e73f66c3efd8e15f92ee7d11be
  #     conclusion 3940b2a6a3d5778297f0e37a06109f9d3dcffe6d
  #
  # @api public
  # @return [String] The object record text.
  objectRecord: () ->
    header = "argument\n\n"
    body = "title #{@title}\n"
    for p in @premises
      body += "premise #{p.sha1()}\n"
    body += "conclusion #{@conclusion.sha1()}\n"
    return header + body

  # Gets the sha1 of the argument's object record.
  #
  # @api public
  # @return [String] The sha1 hex value.
  sha1: () ->
    return crypto.createHash('sha1')
      .update( @objectRecord(), 'utf8' )
      .digest('hex')

  ### Validation ###

  # Validates the argument instance.
  #
  #     isValid = argument.validate()
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      if @validateTitle() and @validatePremises() and @validateConclusion()
        @validationError = null
        @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  # Validates the instance's title.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success
  validateTitle: () ->
    return Argument.validateTitle( @title )

  # Validates the instance's premises.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success
  validatePremises: () ->
    unless @premises instanceof Array and @premises.length >= 0
      throw new Errors.ObjectValidation 'Arguments must have at least one premise.'

    for p in @premises
      unless p instanceof Proposition
        throw new Errors.ObjectValidation 'Argument premises must be propositions.'
      unless p.validate()
        throw p.validationError

    return true

  # Validates the instance's conclusion.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success
  validateConclusion: () ->
    unless @conclusion instanceof Proposition
      throw new Errors.ObjectValidation 'Arguments must have one conclusion.'

    unless @conclusion.validate()
      throw @conclusion.validationError

    return true

  ### Static Methods ###

  # Sanitizes title text.  
  # Strips newlines because titles are included in argument object records.
  #
  # @api private
  # @param [String] text The untrusted title text.
  # @return [String] The safe title text.
  @sanitizeTitle: (text) ->
    text = '' unless _.isString text
    return text.split('\n').join(' ')

  # Validates title text.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] text Title text to validate.
  # @return [Boolean] True only on success.
  @validateTitle: (text) ->
    unless _.isString text
      throw new Errors.ObjectValidation 'Arguments must have a title.'

    unless text.match /\S+/
      throw new Errors.ObjectValidation 'Argument title must not be blank.'

    unless text.length <= @MAX_TITLE_LENGTH
      throw new Errors.ObjectValidation "Argument title must be #{@MAX_TITLE_LENGTH} characters or less."

    return true

module.exports = Argument
