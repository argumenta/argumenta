BaseError     = require '../argumenta/base_error'
ObjectErrors  = require '../argumenta/objects/object_errors'
User          = require '../argumenta/user'
PublicUser    = require '../argumenta/public_user'

class Errors

  @Base:             BaseError

  @User:             UserError = User.Error
  @PublicUser:       PublicUserError = PublicUser.Error

  @Auth:             class AuthError extends BaseError

  @Storage:          class StorageError extends BaseError
  @NotFound:         class NotFoundError extends StorageError
  @StorageConflict:  class ConflictError extends StorageError
  @StorageDeletion:  class StorageDeletionError extends StorageError
  @StorageInput:     class StorageInputError extends StorageError
  @StorageRetrieval: class StorageRetrievalError extends StorageError
  @LocalStore:       class LocalStoreError extends StorageError
  @PostgresStore:    class PostgresStoreError extends StorageError

  @Arguments:        class ArgumentsError extends BaseError
  @Comments:         class CommentsError extends BaseError
  @Discussions:      class DiscussionsError extends BaseError
  @Propositions:     class PropositionsError extends BaseError
  @Publications:     class PublicationsError extends BaseError
  @Repos:            class ReposError extends BaseError
  @Search:           class SearchError extends BaseError
  @Users:            class UsersError extends BaseError

  @Validation:       class ValidationError extends BaseError

  ### Constants ###

  @STATUS_CODES:
    'BaseError'             : 500
    'AuthError'             : 500
    'StorageError'          : 500
    'NotFoundError'         : 404
    'ConflictError'         : 409
    'StorageInputError'     : 400
    'StorageDeletionError'  : 500
    'StorageRetrievalError' : 500
    'LocalStoreError'       : 500
    'UserError'             : 500
    'UsersError'            : 500
    'ValidationError'       : 400
    'ObjectValidationError' : 400

  ### Static Methods ###

  # Gets the HTTP status code for an error.
  #
  # @param [Error] error The error to check for.
  # @return [Number] The status code for that error's type.
  @statusFor: (error) ->
    return @STATUS_CODES[ error.name ] or 500

module.exports = Errors
