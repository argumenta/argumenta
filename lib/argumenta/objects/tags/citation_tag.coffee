Tag = require '../tag'

#
# CitationTag links a target *proposition* with *citation text*.
#
# The citation text informally describes an external resource, and may contain URLs.
#
# @property [String] tagType The tag's type.
# @property [String] targetType The target object's type: 'proposition'.
# @property [String] targetSha1 The target object's sha1 hash.
# @property [String] citationText The citation text.
#
class CitationTag extends Tag

  ### Constructor ###

  # Inits a new CitationTag instance.
  #
  #     targetType = 'proposition'
  #     targetSha1 = '0123456789abcdef000000000000000000000000'
  #     citationText = 'The citation text, with URL: http://wikipedia.org/wiki/Citation'
  #
  #     citationTag = new CitationTag( targetType, targetSha1, citationText )
  #
  # @api public
  # @param [String] targetType The target object's type.
  # @param [String] targetSha1 The target object's sha1 hash.
  # @param [String] citationText The citation text.
  constructor: (@targetType, @targetSha1, @citationText) ->
    if arguments.length is 1
      opts = arguments[0]
      @targetType   = opts.targetType or opts.target_type
      @targetSha1   = opts.targetSha1 or opts.target_sha1
      @citationText = opts.citationText or opts.citation_text

    @tagType = 'citation'

  ### Instance Methods ###

  #### Object Record ####
  #
  # Example usage:
  #
  #     record = tag.objectRecord()
  #
  # Citation tag object records have the form:
  #
  #     tag
  #
  #     tag_type citation
  #     target <target-type> <target-sha1>
  #     citation_text <text>
  #
  # Example object record for citation tag:
  #
  #     tag
  #
  #     tag_type citation
  #     target proposition 0123456789abcdef000000000000000000000000
  #     citation_text The citation text, with URL: http://wikipedia.org/wiki/Citation
  #
  # @see Tag#objectRecord()

  #### Instance Field Validators ####

  # Validates fields for a citation tag instance.
  #
  # Each overrides the corresponding Tag validator,
  # and throws an error on failure, or returns true on success.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success.
  #
  validateFields: () ->
    return @validateTagType() and @validateTarget() and @validateCitationText()

  validateTarget: () ->
    unless @targetType is 'proposition'
      throw new @Errors.ObjectValidation "Citation target type must be 'proposition'."

    return super()

module.exports = CitationTag
