LocalStore = require './storage/local_store'

class Storage

  constructor: (@options = {}) ->
    {storageType} = @options

    switch storageType
      when 'mongo'
        @store = new MongoStore {storageUrl: options.storageUrl}
      when 'local'
        @store = new LocalStore()
      else
        throw new Error 'Missing valid storageType in Storage options: ' + options

  getAllUsers: (cb) ->
    @store.getAllUsers (err, users) ->
      console.error('Error in Storage.getAllUsers: ' + err) if err
      cb null, users

module.exports = Storage
