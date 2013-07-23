
dbm = require 'db-migrate'

exports.up = (db, callback) ->
  db.runSql """
    ALTER TABLE Commits
    ADD COLUMN host VARCHAR(255) NULL;
  """
  callback()

exports.down = (db, callback) ->
  db.runSql """
    ALTER TABLE Commits
    DROP COLUMN host;
  """
  callback()

return module.exports
