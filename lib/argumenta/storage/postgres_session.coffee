{delegate}    = require 'class-delegator'
Transaction   = require 'pg-transaction'
PostgresStore = require './postgres_store'

# PostgresSession provides store functionality within a transaction.
class PostgresSession extends PostgresStore

  # Delegate Transaction's methods to the session's transaction.
  delegate @, 'transaction', Transaction

  constructor: (@connectionUrl, @sessionClient, @transaction) ->

module.exports = PostgresSession
