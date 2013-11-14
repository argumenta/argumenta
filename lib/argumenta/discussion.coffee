_       = require 'underscore'
User    = require '../../lib/argumenta/user'
Commit  = require '../../lib/argumenta/objects/commit'
Errors  = require '../../lib/argumenta/errors'

#
# Discussion represents a conversation about a published argument.
#
# It allows for focused analysis and friendly commentary.
# A few notes:
#
# + The target sha1 identifies the discussed argument.
# + The target owner is the argument's first publisher.
# + A discussion is created by its first participant.
# + A discussion may have multiple participants.
# + Each argument may have multiple discussions.
#
class Discussion

  @ValidationError = Errors.Validation

  # Creates a discussion instance.
  #
  # @api public
  # @param [Object]         params
  # @param [Number]         params.discussionId
  # @param [String]         params.targetType
  # @param [String]         params.targetSha1
  # @param [String]         params.targetOwner
  # @param [String]         params.creator
  # @param [Date]           params.createdAt
  # @param [Date]           params.updatedAt
  # @param [Array<Comment>] params.comments
  constructor: (params) ->
    @discussionId  = params.discussionId  ? params.discussion_id
    @targetType    = params.targetType    ? params.target_type
    @targetSha1    = params.targetSha1    ? params.target_sha1
    @targetOwner   = params.targetOwner   ? params.target_owner
    @creator       = params.creator
    @createdAt     = params.createdAt     ? params.created_at
    @updatedAt     = params.updatedAt     ? params.updated_at
    @comments      = params.comments      ? []

  # Gets a plain object with discussion data.
  #
  # @api public
  # @return [Object] The discussion data.
  data: () ->
    data = {
      discussion_id  : @discussionId
      target_type    : @targetType
      target_sha1    : @targetSha1
      target_owner   : @targetOwner
      creator        : @creator
      created_at     : @createdAt
      updated_at     : @updatedAt
      comments       : (c.data() for c in @comments)
    }
    return data

  ### Validation ###

  # Validates the discussion instance.
  #
  #     isValid = discussion.validate()
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      if @validateDiscussionId() and
         @validateTargetType() and @validateTargetSha1() and
         @validateTargetOwner() and @validateCreator() and
         @validateCreatedAt() and @validateUpdatedAt()
        @validationError = null
        @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  ### Instance Validation ###

  validateDiscussionId: () ->
    return Discussion.validateDiscussionId @discussionId

  validateCreator: () ->
    return Discussion.validateCreator @creator

  validateTargetType: () ->
    return Discussion.validateTargetType @targetType

  validateTargetSha1: () ->
    return Discussion.validateTargetSha1 @targetSha1

  validateTargetOwner: () ->
    return Discussion.validateTargetOwner @targetOwner

  validateCreatedAt: () ->
    return Discussion.validateCreatedAt @createdAt

  validateUpdatedAt: () ->
    return Discussion.validateUpdatedAt @updatedAt

  ### Static Validation ###

  @validateDiscussionId: (discussionId) ->
    unless discussionId?
      return true

    unless _.isNumber discussionId
      throw new @ValidationError "Discussion id must be an integer, if set."

    return true

  @validateCreator: (creator) ->
    try
      User.validateUsername creator
    catch err
      throw new @ValidationError "Discussion creator must be valid."

    return true

  @validateTargetOwner: (targetOwner) ->
    try
      User.validateUsername targetOwner
    catch err
      throw new @ValidationError "Discussion target owner must be valid."

    return true

  @validateTargetType: (targetType) ->
    unless _.isString targetType
      throw new @ValidationError "Discussion target type must be a string."

    unless targetType is 'argument'
      throw new @ValidationError "Discussion target must be an argument."

    return true

  @validateTargetSha1: (sha1) ->
    try
      Commit.validateTargetSha1 sha1
    catch err
      throw new @ValidationError "Discussion target sha1 must be valid."

    return true

  @validateCreatedAt: (createdAt) ->
    unless _.isDate createdAt
      throw new @ValidationError "Discussion created at must be a date."

    return true

  @validateUpdatedAt: (updatedAt) ->
    unless updatedAt?
      return true

    unless _.isDate updatedAt
      throw new @ValidationError "Discussion updated at must be a date, if set."

    return true

module.exports = Discussion
