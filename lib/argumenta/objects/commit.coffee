_      = require 'underscore'
Errors = require './object_errors'
Utils  = require './object_utils'
User   = require '../../argumenta/user'

#
# Commits record a reference to a target object by a user.
#
# @property [String] targetType The type of the target object.
# @property [String] targetSha1 The SHA1 of the target's object record.
# @property [String] committer The username of the committer.
# @property [String] commitDate The commit date, in form: 'YYYY-MM-DDThh:mm:ssZ'.
#
class Commit

  ### Constants ###

  # Instance and static refs to all object errors.
  Errors: @Errors = Errors

  ### Constructor ###

  # Inits a new Commit instance, given a target and committer.
  #
  #     targetType = 'argument'
  #     targetSha1 = '39cb3925a38f954cf4ca12985f5f948177f6da5e'
  #     username   = 'demosthenes'
  #
  #     commit = new Commit( targetType, targetSha1, username )
  #
  # @api public
  # @see Commit.formatDate()
  # @param [String] targetType The type of target: 'argument' or 'tag'.
  # @param [String] targetSha1 The SHA1 of target's object record.
  # @param [String] committer The username of the committer.
  # @param [String] commitDate The commit date string (optional; defaults to the current time).
  # @param [Array<String>] parentSha1s The SHA1s of any parent commits (optional; defaults to none).
  constructor: (@targetType, @targetSha1, @committer, @commitDate, @parentSha1s=[]) ->
    if arguments.length is 1 and arguments[0].committer
      params = arguments[0]
      @targetType  = params.targetType or params.target_type
      @targetSha1  = params.targetSha1 or params.target_sha1
      @committer   = params.committer
      @commitDate  = params.commitDate or params.commit_date
      @parentSha1s = params.parentSha1s or params.parent_sha1s
    @commitDate ?= Commit.formatDate new Date()

  ### Instance Methods ###

  # Gets the commit's object record.
  #
  # Example usage:
  #
  #     record = commit.objectRecord()
  #
  # Commit object records have the form:
  #
  #     commit
  #
  #     <target-type> <target-sha1>
  #     committer <username>
  #     commit_date <date>
  #
  # Example commmit object record:
  #
  #     commit
  #
  #     argument 39cb3925a38f954cf4ca12985f5f948177f6da5e
  #     committer tester
  #     commit_date 1970-01-01T00:00:00Z
  #
  # @api public
  # @see Commit.formatDate()
  # @return [String] The object record text.
  objectRecord: () ->
    head = "commit\n\n"
    body = "#{@targetType} #{@targetSha1}\n"
    body += "parent #{p}\n" for p in @parentSha1s
    body += "committer #{@committer}\n"
    body += "commit_date #{@commitDate}\n"
    return head + body

  # Gets the sha1 of the commit's object record.
  #
  # @api public
  # @return [String] The sha1 hex value.
  sha1: () ->
    return Utils.SHA1 @objectRecord()

  # Gets the commit as plain object data.
  #
  # @api public
  # @return [Object] The commit data.
  data: () ->
    return {
      target_type: @targetType
      target_sha1: @targetSha1
      committer:   @committer
      commit_date: @commitDate
      parent_sha1s: @parentSha1s
    }

  # Checks for equality with another commit.
  #
  #   isEqual = commit1.equals( commit2 )
  #
  # @api public
  # @param [Commit] commit The other commit.
  # @return [Boolean] The equality result.
  equals: (commit) ->
    return commit instanceof Commit and
      @objectRecord() == commit.objectRecord()

  #### Validation ####

  # Validates the commit instance.
  #
  #     isValid = commit.validate()
  #
  # @api public
  # @return [Boolean] The validation status.
  validate: () ->
    try
      if ( @validateTargetType() and @validateTargetSha1() and
           @validateCommitter() and @validateCommitDate() and @validateParentSha1s() )
        @validationError = null
        @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  #### Instance Field Validators ####

  # Validates an instance field.
  #
  # Each calls the static validator with instance parameters.  
  # The static validator throws an error or returns true.
  #
  # @api private
  # @throws ObjectValidationError
  # @return [Boolean] True only on success.
  #
  validateTargetType: () ->
    return Commit.validateTargetType( @targetType )

  validateTargetSha1: () ->
    return Commit.validateTargetSha1( @targetSha1 )

  validateCommitter: () ->
    return Commit.validateCommitter( @committer )

  validateCommitDate: () ->
    return Commit.validateCommitDate( @commitDate )

  validateParentSha1s: () ->
    return Commit.validateParentSha1s( @parentSha1s )

  ### Static Methods ###

  # Returns a commit date string for a given Date.
  #
  # The date string follows this ISO 8601 format:
  #
  #     YY-MM-DDThh:mm:ssZ
  #
  # @api private
  # @param [Date] date The date to format.
  # @return [String] The commit date string.
  @formatDate: (date) ->
    return date.toISOString()
      .replace( /\.\d+Z$/, 'Z' )

  #### Static Validators ####

  # Validates target type of a commit.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] targetType Target type to validate.
  # @return [Boolean] True only on success.
  @validateTargetType: (targetType) ->
    unless targetType?
      throw @Errors.ObjectValidation "Commit target type must exist."

    unless targetType.match /^argument|tag$/
      throw @Errors.ObjectValidation "Commit target type must be argument or tag."

    return true

  # Validates target sha1 of a commit.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] targetSha1 Target sha1 to validate.
  # @return [Boolean] True only on success.
  @validateTargetSha1: (targetSha1) ->
    unless targetSha1?
      throw @Errors.ObjectValidation "Commit target sha1 must exist."

    unless targetSha1.match /^[0-9a-f]{40}$/
      throw @Errors.ObjectValidation "Commit target sha1 must be valid."

    return true

  # Validates committer of a commit.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] committer The username of the committer to validate.
  # @return [Boolean] True only on success.
  @validateCommitter: (committer) ->
    try
      User.validateUsername( committer )
    catch err
      throw @Errors.ObjectValidation "Committer name must be a valid username."

    return true

  # Validates commit date of a commit.
  #
  # @api private
  # @throws ObjectValidationError
  # @param [String] commitDate The commit date to validate.
  # @return [Boolean] True only on success.
  @validateCommitDate: (commitDate) ->
    unless commitDate?
      throw @Errors.ObjectValidation "Commit date must exist."

    unless commitDate.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/
      throw @Errors.ObjectValidation "Commit date must be an ISO 8601 date."

    return true

  # Validates the parents of a commit
  #
  # @api private
  # @throws ObjectValidationError
  # @param [Array<String>] parents The parent SHA1s to validate.
  # @return [Boolean] True only on success.
  @validateParentSha1s: (parentSha1s) ->
    unless _.isArray parentSha1s
      throw Errors.ObjectValidation "Parent sha1s must be an array."

    for parent in parentSha1s
      unless _.isString parent
        throw Errors.ObjectValidation "Each parent sha1 must be a string."
      unless parent.match /^[0-9a-f]{40}$/
        throw Errors.ObjectValidation "Each parent sha1 must be valid."

    return true

module.exports = Commit
