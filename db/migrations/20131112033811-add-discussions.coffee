
dbm = require 'db-migrate'

exports.up = (db, callback) ->
  db.runSql """
    CREATE TABLE IF NOT EXISTS Discussions (
      discussion_id     SERIAL        UNIQUE,
      target_type       VARCHAR(20)   NOT NULL,
      target_sha1       CHAR(40)      NOT NULL,
      target_owner      VARCHAR(20)   NOT NULL,
      creator           VARCHAR(20)   NOT NULL,
      created_at        TIMESTAMP     NOT NULL,
      updated_at        TIMESTAMP     NULL,
      FOREIGN KEY (target_sha1)   REFERENCES Objects(sha1),
      FOREIGN KEY (target_owner)  REFERENCES Users(username),
      FOREIGN KEY (creator)       REFERENCES Users(username)
    );

    CREATE TABLE IF NOT EXISTS Comments (
      comment_id        SERIAL        UNIQUE,
      author            VARCHAR(20)   NOT NULL,
      comment_date      TIMESTAMP     NOT NULL,
      comment_text      VARCHAR(2400) NOT NULL,
      discussion_id     INTEGER       NOT NULL,
      FOREIGN KEY (author)        REFERENCES Users(username),
      FOREIGN KEY (discussion_id) REFERENCES Discussions(discussion_id)
    );

    DROP INDEX IF EXISTS discussions_target_sha1_index;
    DROP INDEX IF EXISTS comments_discussion_id_index;
    CREATE INDEX discussions_target_sha1_index  ON Discussions (target_sha1);
    CREATE INDEX comments_discussion_id_index   ON Comments (discussion_id);
  """
  callback()

exports.down = (db, callback) ->
  db.runSql """
    DROP TABLE Comments;
    DROP TABLE Discussions;
  """
  callback()

return module.exports
