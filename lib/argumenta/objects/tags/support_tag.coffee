Tag = require '../tag'

#
# SupportTag links a target *proposition* with a *source object*.
#
# The source object may be an *argument* or *proposition*.
#
# @property [String] tagType The tag's type.
# @property [String] targetType The target object's type: 'proposition'.
# @property [String] targetSha1 The target object's sha1 hash.
# @property [String] sourceType The source object's type: 'proposition' or 'argument'.
# @property [String] sourceSha1 The source object's sha1 hash.
#
class SupportTag extends Tag

  ### Constructor ###

  # Inits a new SupportTag instance.
  #
  #     targetType = 'proposition'
  #     targetSha1 = '0123456789abcdef000000000000000000000000'
  #     sourceType = 'argument'
  #     sourceSha1 = '1a1a1a1a1a1a1a1a000000000000000000000000'
  #
  #     supportTag = new SupportTag( targetType, targetSha1, targetSha1, sourceSha1 )
  #
  # @api public
  # @param [String] targetType The target object's type.
  # @param [String] targetSha1 The target object's sha1 hash.
  # @param [String] sourceType The source object's type.
  # @param [String] sourceSha1 The source object's sha1 hash.
  constructor: (@targetType, @targetSha1, @sourceType, @sourceSha1) ->
    if arguments.length is 1
      opts = arguments[0]
      @targetType = opts.targetType or opts.target_type
      @targetSha1 = opts.targetSha1 or opts.target_sha1
      @sourceType = opts.sourceType or opts.source_type
      @sourceSha1 = opts.sourceSha1 or opts.source_sha1

    @tagType = 'support'

  ### Instance Methods ###

  #### Object Record ####
  #
  # Example usage:
  #
  #     record = tag.objectRecord()
  #
  # Support tag object records have the form:
  #
  #     tag
  #
  #     tag_type support
  #     target <target-type> <target-sha1>
  #     source <source-type> <source-sha1>
  #
  # Example object record for support tag:
  #
  #     tag
  #
  #     tag_type support
  #     target proposition 0123456789abcdef000000000000000000000000
  #     source argument 1a1a1a1a1a1a1a1a000000000000000000000000
  #
  # @see Tag#objectRecord()

  #### Instance Field Validators ####

  # Validates fields for a support tag instance.
  #
  # Each overrides the corresponding Tag validator,
  # and throws an error on failure, or returns true on success.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success.
  #
  validateFields: () ->
    return @validateTagType() and @validateTarget() and @validateSource()

module.exports = SupportTag
