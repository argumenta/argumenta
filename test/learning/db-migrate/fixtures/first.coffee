
dbm  = require 'db-migrate'

exports.up = (db, callback) ->
  db.runSql """
    CREATE TABLE Cats (
      id        SERIAL        UNIQUE,
      name      VARCHAR(30)   PRIMARY KEY,
      color     VARCHAR(10)   NOT NULL
    );
  """
  callback()

exports.down = (db, callback) ->
  db.runSql """
    DROP TABLE Cats;
  """
  callback()

return module.exports
