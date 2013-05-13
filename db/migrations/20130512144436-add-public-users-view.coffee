
dbm  = require 'db-migrate'

exports.up = (db, callback) ->
  db.runSql """
    CREATE VIEW PublicUsers AS
      SELECT username,
             join_date,
             MD5(LOWER(email)) AS gravatar_id
      FROM Users;
  """
  callback()

exports.down = (db, callback) ->
  db.runSql """
    DROP VIEW PublicUsers;
  """
  callback()

return module.exports

