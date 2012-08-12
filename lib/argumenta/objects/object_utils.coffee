crypto = require 'crypto'

class ObjectUtils

  @SHA1: (data) ->
    return crypto.createHash('sha1')
      .update( data, 'utf8' )
      .digest('hex')

module.exports = ObjectUtils
