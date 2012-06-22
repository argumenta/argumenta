BaseError = require '../argumenta/base_error'

class Errors

  @Base:             BaseError

  @Auth:             class AuthError extends BaseError

  @Storage:          class StorageError extends BaseError
  @StorageConflict:  class ConflictError extends StorageError

  @LocalStore:       class LocalStoreError extends BaseError

  @User:             class UserError extends BaseError

  @Validation:       class ValidationError extends BaseError

module.exports = Errors
