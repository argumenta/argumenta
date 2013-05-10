
CREATE TABLE Users (
  user_id           SERIAL        UNIQUE,
  username          VARCHAR(20)   PRIMARY KEY,
  email             VARCHAR(100)  NOT NULL,
  password_hash     CHAR(60)      NOT NULL,
  join_date         TIMESTAMP     NOT NULL,
  join_ip           INET          NOT NULL
);

CREATE TABLE Objects (
  id                SERIAL        UNIQUE,
  sha1              CHAR(40)      PRIMARY KEY,
  object_type       VARCHAR(20)   NOT NULL,
  object_record     VARCHAR(2000) NOT NULL
);

CREATE TABLE Commits (
  commit_id         SERIAL        UNIQUE,
  commit_sha1       CHAR(40)      PRIMARY KEY,
  committer         VARCHAR(20)   NOT NULL,
  commit_date       CHAR(20)      NOT NULL,
  target_type       VARCHAR(20)   NOT NULL,
  target_sha1       CHAR(40)      NOT NULL,
  parent_sha1s      CHAR(40)[],
  FOREIGN KEY (committer) REFERENCES Users(username),
  FOREIGN KEY (commit_sha1) REFERENCES Objects(sha1),
  FOREIGN KEY (target_sha1) REFERENCES Objects(sha1)
);

CREATE TABLE Arguments (
  argument_id       SERIAL        UNIQUE,
  argument_sha1     CHAR(40)      PRIMARY KEY,
  title             VARCHAR(100)  NOT NULL,
  FOREIGN KEY (argument_sha1) REFERENCES Objects(sha1)
);

CREATE TABLE Propositions (
  proposition_id    SERIAL        UNIQUE,
  proposition_sha1  CHAR(40)      PRIMARY KEY,
  text              VARCHAR(240)  NOT NULL,
  FOREIGN KEY (proposition_sha1) REFERENCES Objects(sha1)
);

CREATE TABLE ArgumentPropositions (
  argument_sha1     CHAR(40)      NOT NULL,
  proposition_sha1  CHAR(40)      NOT NULL,
  position          INTEGER       NOT NULL,
  PRIMARY KEY (argument_sha1, proposition_sha1),
  FOREIGN KEY (argument_sha1) REFERENCES Arguments(argument_sha1),
  FOREIGN KEY (proposition_sha1) REFERENCES Propositions(proposition_sha1)
);

CREATE TABLE Tags (
  tag_id            SERIAL        UNIQUE,
  tag_sha1          CHAR(40)      PRIMARY KEY,
  tag_type          VARCHAR(20)   NOT NULL,
  target_type       VARCHAR(20)   NOT NULL,
  target_sha1       CHAR(40)      NOT NULL,
  source_type       VARCHAR(20)   NULL,  -- Support & dispute tags
  source_sha1       CHAR(40)      NULL,  -- Support & dispute tags
  citation_text     VARCHAR(240)  NULL,  -- Citation tags
  commentary_text   VARCHAR(2400) NULL,  -- Commentary tags
  FOREIGN KEY (tag_sha1) REFERENCES Objects(sha1),
  FOREIGN KEY (target_sha1) REFERENCES Objects(sha1),
  FOREIGN KEY (source_sha1) REFERENCES Objects(sha1)
);

CREATE TABLE Repos (
  repo_id           SERIAL        UNIQUE,
  username          VARCHAR(20),
  reponame          VARCHAR(100),
  commit_sha1       CHAR(40),
  PRIMARY KEY (username, reponame),
  FOREIGN KEY (username) REFERENCES Users(username),
  FOREIGN KEY (commit_sha1) REFERENCES Commits(commit_sha1)
);

CREATE INDEX commit_target_sha1_index ON Commits (target_sha1);
CREATE INDEX tags_target_sha1_index ON Tags (target_sha1);

