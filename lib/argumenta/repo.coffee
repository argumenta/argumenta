PublicUser = require './public_user'
Argument   = require './objects/argument'
Commit     = require './objects/commit'
Errors     = require './errors'
ValidationError = Errors.Validation

#
# Repo represents a user-owned repository.
#
# A repository associates a user and reponame with a commit and target.
#
class Repo

  # The character limit for reponames.
  @MAX_REPONAME_LENGTH: 100

  # Inits a repo instance.
  #
  # Example with individual arguments:
  #
  #     repo = new Repo( user, reponame, commit, target )
  #
  # Example with an options hash:
  #
  #     repo = new Repo( options )
  #
  # @api public
  # @param [PublicUser] user The repo owner.
  # @param [String] reponame The repo's name.
  # @param [Commit] commit The repo's commit.
  # @param [Argument] target The repo commit's target.
  constructor: (@user, @reponame, @commit, @target) ->
    if arguments.length is 1 and arguments[0].reponame
      opts = arguments[0]
      return new Repo opts.user, opts.reponame, opts.commit, opts.target

    @user   = new PublicUser(@user) unless @user instanceof PublicUser
    @commit = new Commit(@commit)   unless @commit instanceof Commit
    @target = new Argument(@target) unless @target instanceof Argument

  # Checks for equality with another repo instance.
  #
  #     isEqual = repo1.equals( repo2 )
  #
  # @api public
  # @return [Boolean] The equality status.
  equals: (repo) ->
    return (
      @reponame == repo.reponame and
      @user.equals(repo.user) and
      @commit.equals(repo.commit) and
      @target.equals(repo.target)
    )

  # Gets the repo info as plain object data.
  #
  #     data = repo.data()
  #
  # @api public
  # @return [Object] The repo data.
  data: () ->
    return {
      username: @user.username
      reponame: @reponame
      user: @user.data()
      commit: @commit.data()
      target: @target.data()
    }

  # Validates the repo instance.
  #
  #     isValid  = repo.validate()
  #     anyError = repo.validationError
  #
  # @api public
  # @return [Boolean] True only on success.
  validate: () ->
    try
      if ( @validateUser() and @validateReponame() and
           @validateCommit() and @validateTarget() )
         @validationError = null
         @validationStatus = true
    catch err
      @validationError = err
      @validationStatus = false
    finally
      return @validationStatus

  #### Instance Validation Methods ####

  # Each validates an instance field by calling the static validator.
  #
  # @api private
  # @throws ValidationError
  # @return [Boolean] True only on success
  #
  validateUser: () ->
    return Repo.validateUser @user

  validateReponame: () ->
    return Repo.validateReponame @reponame

  validateCommit: () ->
    return Repo.validateCommit @commit

  validateTarget: () ->
    return Repo.validateTarget @target

  #### Static Validation Methods ####

  # Each validates the given repo parameter.
  #
  #     try
  #       isValid = Repo.validateUser( user )
  #       validationError = null
  #     catch err
  #       isValid = false
  #       validationError = err
  #
  # @api public
  # @throws ValidationError
  # @return [Boolean] True only on success.
  #
  @validateUser: (user) ->
    unless user instanceof PublicUser
      throw new ValidationError "Repo user must be a public user instance."

    unless user.validate()
      throw new ValidateionError "Repo user must be valid."

    return true

  @validateReponame: (reponame) ->
    unless typeof reponame is 'string'
      throw new ValidationError "Reponame must be a string."

    unless /\S+/.test reponame
      throw new ValidationError "Reponame must not be blank."

    unless reponame.length <= @MAX_REPONAME_LENGTH
      throw new ValidationError """
        Reponame must be #{@MAX_REPONAME_LENGTH} characters or less."""

    return true

  @validateCommit: (commit) ->
    unless commit instanceof Commit
      throw new ValidationError "Repo commit must be a commit object."

    unless commit.validate()
      throw new ValidationError "Repo commit must be valid."

    return true

  @validateTarget: (target) ->
    unless target instanceof Argument
      throw new ValidationError "Repo target must be an argument object."

    unless target.validate()
      throw new ValidationError "Repo target must be valid."

    return true

module.exports = Repo
