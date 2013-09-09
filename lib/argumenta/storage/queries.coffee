_       = require 'underscore'
Objects = require '../../../lib/argumenta/objects'

{ Argument, Proposition, Tag, Commit } = Objects

# Queries builds SQL queries for use with pg's client.query().
#
#     query = Queries.insertArgument arg
#     client.query query, (err, result) ->
#       console.log result
#
class Queries

  ### Helpers ###

  # Parses a Postgres array string and returns a JavaScript array.
  #
  #     Example: "{100,200,300}"
  #     Result:  [ 100, 200, 300 ]
  #
  @parseArray = (string) ->
    elements = string.substr(1, string.length - 2)
    if elements.length is 0
    then return []
    else return elements.split ','

  # Builds a string of positional params for given items.
  #
  #     Example: placeholdersfor( ['a', 'b', 'c'] )
  #     Result : "$1, $2, $3"
  #
  placeholdersFor = (items) ->
    num = items.length
    return "NULL" if num is 0
    placeholders = []
    placeholders.push "$#{ i }" for i in [1..num]
    placeholders = placeholders.join ", "
    return placeholders

  # Builds a string of positional params as a list of tuple pairs.
  #
  #     Example: pairPlaceholdersFor( [['a', 1], ['b', 2], ['c', 3]] )
  #     Result : "($1, $2), ($3, $4), ($5, $6)"
  #
  pairPlaceholdersFor = (pairs) ->
    num = pairs.length
    return '(NULL, NULL)' if num is 0
    placeholders = []
    placeholders.push "($#{2*i - 1}, $#{2*i})" for i in [1..num]
    placeholders.join ', '
    return placeholders

  # Returns the type of an argumenta object.
  getObjectType = (object) ->
    if      object instanceof Argument    then return 'argument'
    else if object instanceof Proposition then return 'proposition'
    else if object instanceof Commit      then return 'commit'
    else if object instanceof Tag         then return 'tag'
    else return null

  ### Queries ###

  # Search arguments by title query.
  @searchArgumentsByTitle: (query, opts={}) ->
    limit  = opts.limit ? 20
    offset = opts.offset ? 0
    return searchArgumentsQuery =
      text: """
        SELECT argument_sha1
        FROM Arguments a
        WHERE to_tsvector(a.title) @@ plainto_tsquery( $1 )
        LIMIT $2 OFFSET $3;
        """
      values: [ query, limit, offset ]

  # Search arguments by full text query.
  @searchArgumentsByFullText: (query, opts={}) ->
    limit  = opts.limit ? 20
    offset = opts.offset ? 0
    return searchArgumentsQuery =
      text: """
        SELECT argument_sha1,
               ts_rank(vector, query) AS rank
        FROM (
               SELECT a.argument_sha1,
                      to_tsvector(
                        u.username || ' ' || a.title || ' ' || string_agg(p.text, ' ')
                      ) AS vector,
                      plainto_tsquery( $1 ) AS query
               FROM Arguments a
               JOIN Commits c ON (a.argument_sha1 = c.target_sha1)
               JOIN Users u ON (c.committer = u.username)
               JOIN ArgumentPropositions ap USING (argument_sha1)
               JOIN Propositions p USING (proposition_sha1)
               GROUP BY c.commit_sha1, a.argument_sha1, u.username
             ) ft
        WHERE vector @@ query
        ORDER BY rank DESC
        LIMIT $2 OFFSET $3;
        """
      values: [ query, limit, offset ]

  # Search arguments by query.
  @searchArguments: @searchArgumentsByFullText

  # Search users by query.
  @searchUsers: (query, opts={}) ->
    limit  = opts.limit ? 20
    offset = opts.offset ? 0
    return searchUsersQuery =
      text: """
        SELECT username
        FROM PublicUsers u
        WHERE to_tsvector(u.username) @@ plainto_tsquery( $1 )
        LIMIT $2 OFFSET $3;
        """
      values: [ query, limit, offset ]

  # Select a user by username.
  @selectUser: (username) ->
    return selectUserQuery =
      text: """
        SELECT username, join_date, gravatar_id
        FROM PublicUsers
        WHERE username = $1;
        """
      values: [username]

  # Select users by usernames.
  @selectUsers: (usernames) ->
    placeholders = placeholdersFor usernames
    return selectUsersQuery =
      text: """
        SELECT username, join_date, gravatar_id
        FROM PublicUsers
        WHERE username IN (#{ placeholders });
        """
      values: usernames

  # Select metadata for users by username.
  @selectUsersMetadata: (usernames) ->
    placeholders = placeholdersFor usernames
    return selectUsersMetadataQuery =
      text: """
        SELECT username,
               COUNT(DISTINCT r.reponame) AS repos_count
        FROM PublicUsers
        JOIN Repos r USING (username)
        WHERE username IN (#{ placeholders })
        GROUP BY username;
        """
      values: usernames

  # List users, starting with the latest.
  @listUsers: (opts={}) ->
    limit  = opts.limit  ? 100
    offset = opts.offset ? 0
    return listUsersQuery =
      text: """
        SELECT username, join_date, gravatar_id
        FROM PublicUsers
        ORDER BY join_date DESC
        LIMIT $1 OFFSET $2;
        """
      values: [limit, offset]

  # List user repos, starting with the latest or earliest.
  @listUserRepos: (username, opts={}) ->
    limit  = opts.limit  ? 50
    offset = opts.offset ? 0
    latest = opts.latest ? true
    orderPlaceholder = if latest then 'DESC' else 'ASC'
    return listUserReposQuery =
      text: """
        SELECT username, reponame
        FROM Repos r
        WHERE username = $1
        ORDER BY repo_id #{ orderPlaceholder }
        LIMIT $2 OFFSET $3;
        """
      values: [username, limit, offset]

  # Select the password hash for the given username.
  @selectPasswordHash: (username) ->
    return selectPasswordHashQuery =
      text: """
        SELECT password_hash FROM Users
        WHERE username = $1;
        """
      values: [username]

  # Insert a repo for the given username, reponame, and commit sha1.
  @insertRepo: (username, reponame, commit_sha1) ->
    return insertRepoQuery =
      text: """
        INSERT INTO Repos (username, reponame, commit_sha1)
        VALUES ($1, $2, $3)
        """
      values: [ username, reponame, commit_sha1 ]

  # Select a repo by username and reponame.
  @selectRepo: (username, reponame) ->
    return selectRepoQuery =
      text: """
        SELECT username, reponame, commit_sha1, p.*, c.*
        FROM Repos r
        JOIN Commits c USING (commit_sha1)
        JOIN PublicUsers p USING (username)
        WHERE (username, reponame) = ($1, $2)
        """
      values: [ username, reponame ]

  # Select repos by [username, reponame] keypairs.
  @selectRepos: (keypairs) ->
    pairPlaceholders = pairPlaceholdersFor( keypairs )
    return selectReposQuery =
      text: """
        SELECT username, reponame, commit_sha1, p.*, c.*
        FROM Repos r
        JOIN Commits c USING (commit_sha1)
        JOIN PublicUsers p USING (username)
        WHERE (username, reponame) IN (VALUES #{ pairPlaceholders } );
        """
      values: _.flatten keypairs

  # Select a commit by its sha1.
  @selectCommitBySha1: (sha1) ->
    return selectCommitQuery =
      name: "select_commit_by_sha1"
      text: """
        SELECT commit_sha1, committer, commit_date,
               target_type, target_sha1, parent_sha1s, host
        FROM Commits
        WHERE commit_sha1 = $1;
        """
      values: [sha1]

  # Select commits by their sha1s.
  @selectCommitsBySha1s: (hashes) ->
    placeholders = placeholdersFor hashes
    return selectCommitsQuery =
      text: """
        SELECT commit_sha1, committer, commit_date,
               target_type, target_sha1, parent_sha1s, host
        FROM Commits
        WHERE commit_sha1 IN (#{ placeholders })
        ORDER BY commit_date ASC;
        """
      values: hashes

  # Select commits by their target sha1s.
  @selectCommitsByTargetSha1s: (targetHashes) ->
    placeholders = placeholdersFor targetHashes
    return selectCommitsQuery =
      text: """
        SELECT commit_sha1, committer, commit_date,
               target_type, target_sha1, parent_sha1s, host
        FROM Commits
        WHERE target_sha1 IN (#{ placeholders });
        """
      values: targetHashes

  # Select arguments by their sha1s.
  @selectArgumentsBySha1s: (hashes) ->
    placeholders = placeholdersFor hashes
    return selectArgumentsQuery =
      text: """
        SELECT a.argument_sha1, a.title, p.text
        FROM Arguments a
        JOIN ArgumentPropositions ap USING(argument_sha1)
        JOIN Propositions p USING (proposition_sha1)
        WHERE a.argument_sha1 IN (#{ placeholders })
        ORDER BY a.argument_sha1, ap.position;
        """
      values: hashes

  # Select propositions by their sha1s.
  @selectPropositionsBySha1s: (hashes) ->
    placeholders = placeholdersFor hashes
    return selectPropositionsQuery =
      text: """
        SELECT proposition_sha1, text
        FROM Propositions
        WHERE proposition_sha1 IN (#{ placeholders });
        """
      values: hashes

  # Select metadata for propositions by their sha1s.
  @selectPropositionsMetadataBySha1s: (hashes) ->
    placeholders = placeholdersFor hashes
    return metadataQuery =
      text: """
        SELECT target_sha1 AS proposition_sha1,
               tag_type,
               tag_sha1
        FROM Tags t
        WHERE t.target_sha1 IN (#{ placeholders });
        """
      values: hashes

  # Selects tags by their sha1s.
  @selectTagsBySha1s: (hashes) ->
    placeholders = placeholdersFor hashes
    return selectTagsQuery =
      text: """
        SELECT tag_sha1, tag_type,
               target_type, target_sha1,
               source_type, source_sha1,
               citation_text, commentary_text
        FROM Tags
        WHERE tag_sha1 IN (#{ placeholders });
        """
      values: hashes

  # Select tags by their target sha1s.
  @selectTagsByTargetSha1s: (targetHashes) ->
    placeholders = placeholdersFor targetHashes
    return selectTagsQuery =
      text: """
        SELECT tag_sha1, tag_type,
               target_type, target_sha1,
               source_type, source_sha1,
               citation_text, commentary_text
        FROM Tags
        WHERE target_sha1 IN (#{ placeholders });
        """
      values: targetHashes

  # Insert a given User.
  @insertUser: (user) ->
    return userQuery =
      text: """
        INSERT INTO Users (username, email, password_hash,
                           join_date, join_ip)
        VALUES ($1, $2, $3, $4, $5);
        """
      values: [ user.username, user.email, user.passwordHash,
                user.joinDate, user.joinIp ]

  # Insert a given Object.
  @insertObject: (object) ->
    return objectQuery =
      name: "insert_object"
      text: """
        INSERT INTO Objects (sha1, object_type, object_record)
        VALUES ($1, $2, $3);
        """
      values: [ object.sha1(), getObjectType(object), object.objectRecord() ]

  # Insert a given Commit.
  @insertCommit: (commit) ->
    parentSha1s = "{ #{commit.parentSha1s.join ', ' } }"
    return commitQuery =
      name: "insert_commit"
      text: """
        INSERT INTO Commits (commit_sha1, committer, commit_date,
                             target_type, target_sha1, parent_sha1s,
                             host)
        VALUES ($1, $2, $3,
                $4, $5, $6,
                $7);
        """
      values: [ commit.sha1(), commit.committer, commit.commitDate,
                commit.targetType, commit.targetSha1, parentSha1s,
                commit.host ]

  # Insert a given Argument.
  @insertArgument: (argument) ->
    return argumentQuery =
      name: "insert_argument"
      text: """
        INSERT INTO Arguments (argument_sha1, title)
        VALUES ($1, $2);
        """
      values: [ argument.sha1(), argument.title ]

  # Insert a given Proposition.
  @insertProposition: (proposition) ->
    return propositionQuery =
      name: "insert_proposition"
      text: """
        INSERT INTO Propositions (proposition_sha1, text)
        VALUES ($1, $2);
        """
      values: [ proposition.sha1(), proposition.text ]

  # Insert a listing for a Proposition used in the given Argument.
  @insertArgumentProposition: (argument, proposition, position) ->
    return argPropQuery =
      name: "insert_argument_proposition"
      text: """
        INSERT INTO ArgumentPropositions (argument_sha1, proposition_sha1, position)
        VALUES ($1, $2, $3);
        """
      values: [ argument.sha1(), proposition.sha1(), position ]

  # Insert a given Tag.
  @insertTag: (tag) ->
    return tagQuery =
      name: "insert_tag"
      text: """
        INSERT INTO Tags (tag_sha1, tag_type,
                          target_type, target_sha1,
                          source_type, source_sha1,
                          citation_text, commentary_text)
        VALUES ( $1, $2,
                 $3, $4,
                 $5, $6,
                 $7, $8 );
        """
      values: [
        tag.sha1(), tag.tagType,
        tag.targetType, tag.targetSha1,
        tag.sourceType, tag.sourceSha1,
        tag.citationText, tag.commentaryText
      ]

  # Deletes a repo by owner and name.
  @deleteRepo: (username, reponame) ->
    return deleteRepoQuery =
      text: """
        DELETE FROM Repos
        WHERE (username, reponame) = ($1, $2);
        """
      values: [ username, reponame ]

  # Delete all rows from the database.
  # @note Faster than truncation for small tables; useful for tests.
  @deleteAll: () ->
    return deleteAllQuery = """
      DELETE FROM Repos;
      DELETE FROM Commits;
      DELETE FROM Tags;
      DELETE FROM ArgumentPropositions;
      DELETE FROM Arguments;
      DELETE FROM Propositions;
      DELETE FROM Objects;
      DELETE FROM Users;
      """

  # Truncate all database tables.
  @truncateAll: () ->
    return truncateAllQuery = """
      TRUNCATE Users, Objects, Propositions, Arguments,
               ArgumentPropositions, Tags, Commits, Repos
      RESTART IDENTITY
      CASCADE;
      """

module.exports = Queries
