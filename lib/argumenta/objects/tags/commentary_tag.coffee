Tag = require '../tag'

#
# CommentaryTag links an *argument* with *commentary text*.
#
# The commentary text allows for analysis of an argument in a few paragraphs.
#
# @property [String] tagType The tag's type.
# @property [String] targetType The target object's type: 'argument'.
# @property [String] targetSha1 The target object's sha1 hash.
# @property [String] commentaryText The commentary text.
#
class CommentaryTag extends Tag

  ### Constructor ###

  # Inits a new CommentaryTag instance.
  #
  #     targetType = 'argument'
  #     targetSha1 = '0123456789abcdef000000000000000000000000'
  #     commentaryText = 'The commentary analysis, up to a few paragraphs...'
  #
  #     commentaryTag = new commentaryTag( targetType, targetSha1, commentaryTag )
  #
  # @api public
  # @param [String] targetType The target object's type.
  # @param [String] targetSha1 The target object's sha1 hash.
  # @param [String] commentaryText The commentary text.
  constructor: (@targetType, @targetSha1, @commentaryText) ->
    if arguments.length is 1
      opts = arguments[0]
      @targetType     = opts.targetType or opts.target_type
      @targetSha1     = opts.targetSha1 or opts.target_sha1
      @commentaryText = opts.commentaryText or opts.commentary_text

    @tagType = 'commentary'

  ### Instance Methods ###

  #### Object Record ####
  #
  # Example usage:
  #
  #     record = tag.objectRecord()
  #
  # Commentary tag object records have the form:
  #
  #     tag
  #
  #     tag_type commentary
  #     target <target-type> <target-sha1>
  #     commentary_text <text>
  #
  # Example object record for commentary tag:
  #
  #     tag
  #
  #     tag_type commentary
  #     target argument 1a1a1a1a1a1a1a1a000000000000000000000000
  #     commentary_text The commentary analysis, up to a few paragraphs...
  #
  # @see Tag#objectRecord()

  #### Instance Field Validators ####

  # Validates fields for a commentary tag instance.
  #
  # Each overrides the corresponding Tag validator,
  # and throws an error on failure, or returns true on success.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success.
  #
  validateFields: () ->
    return @validateTagType() and @validateTarget() and @validateCommentaryText()

  validateTarget: () ->
    unless @targetType is 'argument'
      throw new @Errors.ObjectValidation "Commentary target type must be 'argument'."

    return super()

module.exports = CommentaryTag
