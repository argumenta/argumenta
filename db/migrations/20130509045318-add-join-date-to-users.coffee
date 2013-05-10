
dbm  = require 'db-migrate'

exports.up = (db, callback) ->
  db.runSql """
    ALTER TABLE Users
    ADD COLUMN join_date  TIMESTAMP   NOT NULL,
    ADD COLUMN join_ip    INET        NOT NULL;
  """
  callback()

exports.down = (db, callback) ->
  db.runSql """
    ALTER TABLE Users
    DROP COLUMN join_date,
    DROP COLUMN join_ip;
  """
  callback()

return module.exports
