
Middleware =
  reply    : require './reply'
  success  : require './success'
  created  : require './created'
  failed   : require './failed'
  notFound : require './not_found'

module.exports = Middleware
