Base = require '../argumenta/base'

class Errors

  @Auth:             class AuthError extends Base.Error

  @Storage:          class StorageError extends Base.Error
  @StorageConflict:  class ConflictError extends StorageError

  @LocalStore:       class LocalStoreError extends Base.Error

  @User:             class UserError extends Base.Error

  @Validation:       class ValidationError extends Base.Error

module.exports = Errors
