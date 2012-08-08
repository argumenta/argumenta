
#
# `ObjectErrors` contains errors related to Argumenta objects.
#
# The object errors inheritance hierarchy:
#
#     Error
#     `-- ObjectError
#         `-- ObjectValidationError
#
# @property [ObjectError] ObjectErrors.Object
# @property [ObjectValidationError] ObjectErrors.ObjectValidation
#
class ObjectErrors

  @Object = class ObjectError extends Error
  @ObjectValidation = class ObjectValidationError extends ObjectError

module.exports = ObjectErrors
