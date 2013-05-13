crypto = require 'crypto'
_      = require 'underscore'

class ObjectUtils

  # Computes the SHA1 hash of a UTF-8 string.
  #
  # @api private
  # @param [String] string The string to hash.
  # @return [String] The SHA1 hex value.
  @SHA1: (string) ->
    return crypto.createHash('sha1')
      .update( string, 'utf8' )
      .digest('hex')

  # Computes the MD5 hash of a UTF-8 string.
  #
  # @api private
  # @param [String] string The string to hash.
  # @return [String] The MD5 hex value.
  @MD5: (string) ->
    return crypto.createHash('md5')
      .update( string, 'utf8' )
      .digest('hex')

  # Determines if a value is a valid SHA1 string.
  #
  # @param [Object] value The value to test.
  # @return [Boolean] True or false.
  @isSHA1: (value) ->
    return _.isString( value ) and value.match /^[0-9a-f]{40}$/

module.exports = ObjectUtils
