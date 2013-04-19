
Middleware =
  gzipped  : require './gzipped'
  globals  : require './globals'
  locals   : require './locals'
  reply    : require './reply'
  success  : require './success'
  created  : require './created'
  failed   : require './failed'
  notFound : require './not_found'

module.exports = Middleware
