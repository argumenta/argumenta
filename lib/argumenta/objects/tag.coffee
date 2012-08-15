_      = require 'underscore'
Errors = require './object_errors'
Utils  = require './object_utils'

#
# Tags represent a link between a *target object* and *source content*.
#
# **Support** and **dispute** tags link a target *proposition* with a *source object*.  
# Source objects may be an *argument* or *proposition*.
#
# **Citation** tags link a target *proposition* with *citation text*.  
# Citation text informally describes an external resource, and may contain URLs.
#
# **Commentary** tags link a target *argument* with *commentary text*.  
# Commentary text allows for analysis of an argument in a few paragraphs.
#
# @see SupportTag, DisputeTag, CitationTag, CommentaryTag
#
class Tag

  ### Constants ###

  # Instance and static refs to all object errors.
  Errors: @Errors = Errors

  # The character limit for citation text.
  @MAX_CITATION_LENGTH: 240

  # The character limit for commentary text.
  @MAX_COMMENTARY_LENGTH: 2400

  ### Constructor ###

  # Inits a new Tag instance for the given tag type.
  #
  #     supportTag    = new Tag('support', targetType, targetSha1, sourceType, sourceSha1)
  #     disputeTag    = new Tag('dispute', targetType, targetSha1, sourceType, sourceSha1)
  #     citationTag   = new Tag('citation', targetType, targetSha1, citationText)
  #     commentaryTag = new Tag('commentary', targetType, targetSha1, commentaryText)
  #
  # @api public
  # @see SupportTag, DisputeTag, CitationTag, CommentaryTag
  # @param [String] tagType The type of tag to construct.
  # @param [String] params... A series of params accepted by that constructor.
  constructor: (tagType, params...) ->
    Tags = require './tags'

    switch tagType
      when 'support' then Constructor = Tags.SupportTag
      when 'dispute' then Constructor = Tags.DisputeTag
      when 'citation' then Constructor = Tags.CitationTag
      when 'commentary' then Constructor = Tags.CommentaryTag
      else throw new @Errors.Object "Invalid tag type."

    return new Constructor(params[0], params[1], params[2], params[3])

  ### Instance Methods ###

  # Gets the tag's object record.
  #
  # Example usage:
  #
  #     record = tag.objectRecord()
  #
  # Support and dispute tag object records have the form:
  #
  #     tag
  #
  #     tag_type (support|dispute)
  #     target <target-type> <target-sha1>
  #     source <source-type> <source-sha1>
  #
  # Citation and commentary tag object records have the form:
  #
  #     tag
  #
  #     tag_type (citation|commentary)
  #     target <target-type> <target-sha1>
  #     (citation_text|commentary_text) <text>
  #
  # See each module's docs for a concrete example.
  #
  # @api public
  # @see objectRecord() of SupportTag, DisputeTag, CitationTag, CommentaryTag
  # @return [String] The object record text.
  objectRecord: () ->
    head = "tag\n\n"
    body = "tag_type #{@tagType}\n"
    body += "target #{@targetType} #{@targetSha1}\n"
    body += "source #{@sourceType} #{@sourceSha1}\n" if @tagType.match /^support|dispute$/
    body += "citation_text #{@citationText}\n" if @tagType is 'citation'
    body += "commentary_text #{@commentaryText}\n" if @tagType is 'commentary'
    return head + body

  # Gets the sha1 of the tag's object record.
  #
  #     sha1 = tag.sha1()
  #
  # @api public
  # @return [String] The sha1 hex value.
  sha1: () ->
    return Utils.SHA1 @objectRecord()

  #### Validation ####

  # Validates the tag instance.
  #
  #     isValid = tag.validate()
  #     anyError = tag.validationError
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      if @validateFields()
        @validationError = null
        @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  #### Instance Field Validators ####

  # Abstract method for validating instance properties.
  #
  # @api private
  # @throws ObjectValidationError
  validateFields: () ->
    throw new @Errors.ObjectValidation """
      Tag subclasses should override validateFields()."""

  # Validates fields for tag instances.
  #
  # Each throws an error on failure, or returns true on success.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success.
  #
  validateTagType: () ->
    return Tag.validateTagType( @tagType )

  validateTarget: () ->
    return Tag.validateTargetType( @targetType ) and
           Tag.validateTargetSha1( @targetSha1 )

  validateSource: () ->
    return Tag.validateSourceType( @sourceType ) and
           Tag.validateSourceSha1( @sourceSha1 )

  validateCitationText: () ->
    return Tag.validateCitationText( @citationText )

  validateCommentaryText: () ->
    return Tag.validateCommentaryText( @commentaryText )

  ### Static Methods ###

  # Validates tag type of a tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] tagType Tag type to validate.
  # @return [Boolean] True only on success.
  @validateTagType: (tagType) ->
    unless _.isString tagType
      throw new @Errors.ObjectValidation "Tag type must be a string."

    unless tagType.match /^support|dispute|citation|commentary$/
      throw new @Errors.ObjectValidation """
        Tag type must be 'support', 'dispute', 'citation', or 'commentary'."""

    return true

  # Validates target type of a tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] targetType Target type to validate.
  # @return [Boolean] True only on success.
  @validateTargetType: (targetType) ->
    unless _.isString targetType
      throw new @Errors.ObjectValidation "Target type must be a string"

    unless targetType.match /^proposition|argument$/
      throw new @Errors.ObjectValidation """
        Target type must be 'proposition' or 'argument'."""

    return true

  # Validates target sha1 of a tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] targetSha1 Target SHA1 to validate.
  # @return [Boolean] True only on success.
  @validateTargetSha1: (targetSha1) ->
    unless Utils.isSHA1 targetSha1
      throw new @Errors.ObjectValidation "Target sha1 must be a valid sha1 string."

    return true

  # Validates source type of a tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] sourceType Source type to validate.
  # @return [Boolean] True only on success.
  @validateSourceType: (sourceType) ->
    unless _.isString sourceType
      throw new @Errors.ObjectValidation "Source type must be a string"

    unless sourceType.match /^argument|proposition$/
      throw new @Errors.ObjectValidation "Source type must be 'argument' or 'proposition'."

    return true

  # Validates source sha1 of a tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] targetSha1 Source SHA1 to validate.
  # @return [Boolean] True only on success.
  @validateSourceSha1: (sourceSha1) ->
    unless Utils.isSHA1 sourceSha1
      throw new @Errors.ObjectValidation "Source sha1 must be a valid sha1 string."

    return true

  # Validates citation text of a citation tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] citationText Citation text to validate.
  # @return [Boolean] True only on success.
  @validateCitationText: (citationText) ->
    unless _.isString citationText
      throw new @Errors.ObjectValidation "Citation text must be a string."

    unless citationText.match /\S+/
      throw new @Errors.ObjectValidation "Citation text must not be blank."

    unless citationText.length <= @MAX_CITATION_LENGTH
      throw new @Errors.ObjectValidation """
        Citation text must be #{@MAX_CITATION_LENGTH} characters or less."""

    return true

  # Validates commentary text of a commentary tag.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] commentaryText Commentary text to validate.
  # @return [Boolean] True only on success.
  @validateCommentaryText: (commentaryText) ->
    unless _.isString commentaryText
      throw new @Errors.ObjectValidation "Commentary text must be a string."

    unless commentaryText.match /\S+/
      throw new @Errors.ObjectValidation "Commentary text must not be blank."

    unless commentaryText.length <= @MAX_COMMENTARY_LENGTH
      throw new @Errors.ObjectValidation """
        Commentary text must be #{@MAX_COMMENTARY_LENGTH} characters or less."""

    return true

module.exports = Tag
