
<!--

    # These requests run first when building API docs.

    # POST /users.json
    curl -i -X POST http://localhost:3000/users.json \
      -d 'username=tester' \
      -d 'password=tester12' \
      -d 'email=tester@xyz.com' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 221
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tester",
      "message": "Welcome aboard, tester!",
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "error": null
    }

    # POST /arguments.json
    curl -i -X POST http://localhost:3000/arguments.json \
      -d 'title=My Argument ^_^' \
      -d 'premises=First premise.' \
      -d 'premises=Second premise.' \
      -d 'conclusion=The conclusion! :D' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 378
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tester/my-argument-^_^",
      "message": "Created a new argument!",
      "argument": {
        "title": "My Argument ^_^",
        "premises": [
          "First premise.",
          "Second premise."
        ],
        "conclusion": "The conclusion! :D",
        "object_type": "argument",
        "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
        "repo": "my-argument-^_^"
      },
      "error": null
    }

    # POST /tags.json
    curl -i -X POST http://localhost:3000/tags.json \
      -d 'tag_type=citation' \
      -d 'target_type=proposition' \
      -d 'target_sha1=30be8f3b68d20f5c3898265e33c583ddee374a6a' \
      -d 'citation_text=The citation text, with url: http://wikipedia.org/wiki/Citation' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 423
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tags/412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae",
      "message": "Created a new tag!",
      "tag": {
        "object_type": "tag",
        "tag_type": "citation",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
        "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
      },
      "error": null
    }

    # POST /tags.json
    curl -i -X POST http://localhost:3000/tags.json \
      -d 'tag_type=support' \
      -d 'target_type=proposition' \
      -d 'target_sha1=30be8f3b68d20f5c3898265e33c583ddee374a6a' \
      -d 'source_type=proposition' \
      -d 'source_sha1=dfe2394f3cdad27e56023cd0574be36b9a5f9e6e' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 431
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tags/08f6c25476af45f8d8ee4cb0601740bc7bf098ab",
      "message": "Created a new tag!",
      "tag": {
        "object_type": "tag",
        "tag_type": "support",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "source_type": "proposition",
        "source_sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
        "sha1": "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
      },
      "error": null
    }

-->

# Argumenta API

## [Overview](#overview) / [Features](#features) / [Routes](#routes) / [Usage](#usage) / [Changes](#changes)

<a name="overview"></a>
## Overview

The Argumenta API provides a RESTful interface to data in JSON form.

It can be used to access resources including Users, Repos, Arguments, Propositions, and Tags.  
Search is now also available.
Planned resources include Follows and Activity.

<a name="features"></a>
## Features

The current version (0.1.0) provides the following features:

+ Read access for general use by unauthenticated clients.
+ Cookie-based authenticated sessions for account creation, login, and publishing.
+ JSON and JSONP response formats via the extensions '.json' and '.jsonp'.

<a name="routes"></a>
## Routes

### [Users](#users)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#get-users-user">GET /users/:user.json</a></td>
    <td width="300px">Get a user's account info.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#get-user">GET /:user.json</a></td>
    <td width="300px">Get a user's account and argument repos.</td>
  </tr>
</table>

### [Repos](#repos)


<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#get-user-repo">GET /:user/:repo.json</a></td>
    <td width="300px">Get a repo owned by a user.</td>
  </tr>
</table>

### [Arguments](#arguments)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#get-argument">GET /arguments/:sha1.json</td>
    <td width="300px">Get an argument by its sha1.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#get-argument-propositions">GET /arguments/:sha1/propositions.json</td>
    <td width="300px">Get an argument's propositions.</td>
  </tr>
</table>

### [Propositions](#propositions)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#get-proposition">GET /propositions/:sha1.json</td>
    <td width="300px">Get a proposition by its sha1.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#get-proposition-tags">GET /propositions/:sha1/tags.json</td>
    <td width="300px">Get a proposition's tags.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#get-proposition-tags-plus-sources">GET /propositions/:sha1/tags-plus-sources.json</td>
    <td width="300px">Get a proposition's tags (plus source objects).</td>
  </tr>
</table>

### [Tags](#tags)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#get-tag">GET /tags/:sha1.json</td>
    <td width="300px">Get a tag by its sha1.</td>
  </tr>
</table>

### [Search](#search)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#search-by-query">GET /search.json</td>
    <td width="300px">Search for users, arguments, props, tags.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#search-by-query">GET /search/:query.json</td>
    <td width="300px">Search for users, arguments, props, tags.</td>
  </tr>
</table>

## Session Routes (Authenticated)

### [Join](#join)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#post-users">POST /users.json</td>
    <td width="300px">Create a new user account.</td>
  </tr>
</table>

### [Login](#login)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#post-login">POST /login.json</td>
    <td width="300px">Start an authenticated user session.</td>
  </tr>
  <tr>
    <td width="300px"><a href="#get-logout">GET /logout.json</td>
    <td width="300px">End the current user session.</td>
  </tr>
</table>

### [Publish](#publish)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#post-arguments">POST /arguments.json</td>
    <td width="300px">Create a new argument (with repo).</td>
  </tr>
  <tr>
    <td width="300px"><a href="#post-tags">POST /tags.json</td>
    <td width="300px">Create a new tag (support, dispute, citation, or commentary).</td>
  </tr>
</table>

### [Delete](#delete)

<table class="routes" width="600px">
  <tr>
    <td width="300px"><a href="#delete-repo">DELETE /:name/:repo.json</td>
    <td width="300px">Delete a repo.</td>
  </tr>
</table>

<a name="usage"></a>
## Usage

### 1. Errors

On error, Argumenta returns one of the following HTTP status codes:

+ 400 (Bad Request)
+ 401 (Unauthorized)
+ 404 (Not Found)
+ 409 (Resource Conflict)
+ 500 (Internal Server Error)

Also, the JSON should contain an "error" property with a message describing the problem.

### 2. JSONP

Each resource is available as json or jsonp.
To make a JSONP request, use the extension `.jsonp`.

#### Example: JSONP Request

Here, we access the user `tester`, replacing the regular `.json` extension with `.jsonp`:

    curl -i 'http://localhost:3000/users/tester.jsonp'

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: text/javascript
    Content-Length: 177
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    jsonpCallback({
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "error": null
    });

Note the response is padded with a call to our default callback, `jsonpCallback()`.

#### Example: JSONP Request with a Custom Callback Name

You can change the callback name by adding a `callback` parameter to the url.

Here we set the callback to `myCb` by adding `?callback=myCb`:

    curl -i 'http://localhost:3000/users/tester.jsonp?callback=myCb'

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: text/javascript
    Content-Length: 168
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    myCb({
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "error": null
    });

<a name="users"></a>
## Users [&para;](#users)

<a name="get-users-user"></a>
### GET /users/:user.json

*Get a user's account info.*

#### Params

+ user: The user's username.

#### Example

    curl -i localhost:3000/users/tester.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 161
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "error": null
    }

<a name="get-user"></a>
### GET /:user.json

*Get a user's account and argument repos.*

### Params

+ user: The user's username.

### Example

    curl -i localhost:3000/tester.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 1109
    ETag: "-490540357"
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "repos": [
        {
          "username": "tester",
          "reponame": "my-argument-^_^",
          "user": {
            "username": "tester",
            "join_date": "2013-08-12T13:52:38.210Z",
            "gravatar_id": "cf3321b32988beb65273932bf8de619e"
          },
          "commit": {
            "object_type": "commit",
            "sha1": "b799d1f8b105068810fedc73d5660167289bbfaa",
            "target_type": "argument",
            "target_sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
            "committer": "tester",
            "commit_date": "2013-08-12T13:52:38Z",
            "parent_sha1s": [],
            "host": "testing.argumenta.io"
          },
          "target": {
            "title": "My Argument ^_^",
            "premises": [
              "First premise.",
              "Second premise."
            ],
            "conclusion": "The conclusion! :D",
            "object_type": "argument",
            "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
            "repo": "my-argument-^_^"
          }
        }
      ],
      "error": null
    }

<a name="repos"></a>
## Repos [&para;](#repos)

<a name="get-user-repo"></a>
### GET /:user/:repo.json

*Get a repo owned by a user.*

#### Params

+ user: The repo owner's username.
+ repo: The repo name.

#### Example

    curl -i http://localhost:3000/tester/my-argument-^_^.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 898
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "repo": {
        "username": "tester",
        "reponame": "my-argument-^_^",
        "user": {
          "username": "tester",
          "join_date": "2013-08-12T13:52:38.210Z",
          "gravatar_id": "cf3321b32988beb65273932bf8de619e"
        },
        "commit": {
          "object_type": "commit",
          "sha1": "b799d1f8b105068810fedc73d5660167289bbfaa",
          "target_type": "argument",
          "target_sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
          "committer": "tester",
          "commit_date": "2013-08-12T13:52:38Z",
          "parent_sha1s": [],
          "host": "testing.argumenta.io"
        },
        "target": {
          "title": "My Argument ^_^",
          "premises": [
            "First premise.",
            "Second premise."
          ],
          "conclusion": "The conclusion! :D",
          "object_type": "argument",
          "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
          "repo": "my-argument-^_^"
        }
      },
      "error": null
    }

<a name="arguments"></a>
## Arguments [&para;](#arguments)

<a name="get-argument"></a>
### GET /arguments/:sha1.json

*Get an argument by its sha1.*

#### Params

+ sha1 - The argument's sha1.

#### Notes

+ Includes the argument's original commit for convenience.

#### Example

    curl -i http://localhost:3000/arguments/675f1c4a2a2bec4fa1e5b745a4b94322dda294e6.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 629
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "argument": {
        "title": "My Argument ^_^",
        "premises": [
          "First premise.",
          "Second premise."
        ],
        "conclusion": "The conclusion! :D",
        "object_type": "argument",
        "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
        "repo": "my-argument-^_^"
      },
      "commit": {
        "object_type": "commit",
        "sha1": "b799d1f8b105068810fedc73d5660167289bbfaa",
        "target_type": "argument",
        "target_sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
        "committer": "tester",
        "commit_date": "2013-08-12T13:52:38Z",
        "parent_sha1s": [],
        "host": "testing.argumenta.io"
      },
      "error": null
    }

<a name="argument-propositions"></a>
## Argument Propositions [&para;](#argument-propositions)

<a name="get-argument-propositions"></a>
### GET /arguments/:sha1/propositions.json

*Get an argument's propositions.*

#### Params

+ sha1 - The argument's sha1.

#### Example

    curl -i http://localhost:3000/arguments/675f1c4a2a2bec4fa1e5b745a4b94322dda294e6/propositions.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 1789
    ETag: "1174394911"
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "argument": {
        "title": "My Argument ^_^",
        "premises": [
          "First premise.",
          "Second premise."
        ],
        "conclusion": "The conclusion! :D",
        "object_type": "argument",
        "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
        "repo": "my-argument-^_^"
      },
      "propositions": [
        {
          "text": "First premise.",
          "object_type": "proposition",
          "sha1": "49cb32b909f2cdfad750fd76af83a126414d0e7a",
          "metadata": {
            "sha1": "49cb32b909f2cdfad750fd76af83a126414d0e7a",
            "tag_sha1s": {
              "support": [],
              "dispute": [],
              "citation": []
            },
            "tag_counts": {
              "support": 0,
              "dispute": 0,
              "citation": 0
            }
          }
        },
        {
          "text": "Second premise.",
          "object_type": "proposition",
          "sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "metadata": {
            "sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
            "tag_sha1s": {
              "support": [
                "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
              ],
              "dispute": [],
              "citation": [
                "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
              ]
            },
            "tag_counts": {
              "support": 1,
              "dispute": 0,
              "citation": 1
            }
          }
        },
        {
          "text": "The conclusion! :D",
          "object_type": "proposition",
          "sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
          "metadata": {
            "sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
            "tag_sha1s": {
              "support": [],
              "dispute": [],
              "citation": []
            },
            "tag_counts": {
              "support": 0,
              "dispute": 0,
              "citation": 0
            }
          }
        }
      ],
      "error": null
    }

<a name="propositions"></a>
## Propositions [&para;](#propositions)

<a name="get-proposition"></a>
### GET /propositions/:sha1.json

*Get a proposition by its sha1.*

#### Params

+ sha1: The proposition's sha1.

#### Returns

+ Success: 200 (OK)
+ Error: 404 (Not Found)

#### Example

    curl -i http://localhost:3000/propositions/30be8f3b68d20f5c3898265e33c583ddee374a6a.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 565
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "proposition": {
        "text": "Second premise.",
        "object_type": "proposition",
        "sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "metadata": {
          "sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "tag_sha1s": {
            "support": [
              "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
            ],
            "dispute": [],
            "citation": [
              "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
            ]
          },
          "tag_counts": {
            "support": 1,
            "dispute": 0,
            "citation": 1
          }
        }
      },
      "error": null
    }

<a name="get-proposition-tags"></a>
### GET /propositions/:sha1/tags.json

*Get a proposition's tags.*

#### Params

+ sha1: The proposition's sha1.

#### Returns

+ Success: 200 (OK)

#### Example

    curl -i http://localhost:3000/propositions/30be8f3b68d20f5c3898265e33c583ddee374a6a/tags.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 683
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "tags": [
        {
          "object_type": "tag",
          "tag_type": "citation",
          "target_type": "proposition",
          "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
          "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
        },
        {
          "object_type": "tag",
          "tag_type": "support",
          "target_type": "proposition",
          "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "source_type": "proposition",
          "source_sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
          "sha1": "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
        }
      ],
      "error": null
    }

<a name="get-proposition-tags-plus-sources"></a>
### GET /propositions/:sha1/tags-plus-sources.json

*Get a proposition's tags (plus source objects).*

#### Params

+ sha1: The proposition's sha1.

#### Returns

+ Success: 200 (OK)

#### Example

    curl -i http://localhost:3000/propositions/30be8f3b68d20f5c3898265e33c583ddee374a6a/tags-plus-sources.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 1527
    ETag: "-1410336478"
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "tags": [
        {
          "object_type": "tag",
          "tag_type": "citation",
          "target_type": "proposition",
          "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
          "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
        },
        {
          "object_type": "tag",
          "tag_type": "support",
          "target_type": "proposition",
          "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
          "source_type": "proposition",
          "source_sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
          "sha1": "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
        }
      ],
      "sources": [
        {
          "text": "The conclusion! :D",
          "object_type": "proposition",
          "sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e"
        }
      ],
      "commits": [
        {
          "object_type": "commit",
          "sha1": "8632d73db730388c447ddc64287d85d734abaaec",
          "target_type": "tag",
          "target_sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae",
          "committer": "tester",
          "commit_date": "2013-08-12T13:52:38Z",
          "parent_sha1s": [],
          "host": "testing.argumenta.io"
        },
        {
          "object_type": "commit",
          "sha1": "db8f59bdafb0d45a99cc96c012993294dc73fcb3",
          "target_type": "tag",
          "target_sha1": "08f6c25476af45f8d8ee4cb0601740bc7bf098ab",
          "committer": "tester",
          "commit_date": "2013-08-12T13:52:38Z",
          "parent_sha1s": [],
          "host": "testing.argumenta.io"
        }
      ],
      "error": null
    }

<a name="tags"></a>
## Tags [&para;](#tags)

<a name="get-tag"></a>
### GET /tags/:sha1.json

*Get a tag by its sha1.*

#### Params

+ sha1: The tag's sha1.

#### Returns

+ Success: 200 (OK)
+ Error: 404 (Not Found)

#### Example

    curl -i http://localhost:3000/tags/412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 329
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "tag": {
        "object_type": "tag",
        "tag_type": "citation",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
        "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
      },
      "error": null
    }

<a name="search"></a>
## Search [&para;](#search)

<a name="search-by-query"></a>
### GET /search.json
### GET /search/:query.json

*Search by query for users, arguments, propositions, and tags.*

#### Notes

For convenience, you may use the `query` param in the URL's path or query string.

#### Params

+ query: The search query. (Example: "My Argument")

#### Returns

+ Success: 200 (OK)
+ Error: 404 (Not Found)

#### Example with search in query string

    curl -i http://localhost:3000/search.json?query=My+Argument

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 333
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "arguments": [
        {
          "title": "My Argument ^_^",
          "premises": [
            "First premise.",
            "Second premise."
          ],
          "conclusion": "The conclusion! :D",
          "object_type": "argument",
          "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
          "repo": "my-argument-^_^"
        }
      ],
      "error": null
    }

#### Example with search in path

    curl -i http://localhost:3000/search/My%20Argument.json

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 333
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%7D.IduvgXvQtLWjWRgMgYx6LR8eowjCrldCZ8%2BbbmP3IUvBsdFXC19UyOLesqZ5p%2FM5Ez2cVZx%2FaFZgEQy%2B%2BZYsfw; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "arguments": [
        {
          "title": "My Argument ^_^",
          "premises": [
            "First premise.",
            "Second premise."
          ],
          "conclusion": "The conclusion! :D",
          "object_type": "argument",
          "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
          "repo": "my-argument-^_^"
        }
      ],
      "error": null
    }


<!--

    # These requests run after public routes when building API docs.

    # DELETE (Setup)
    curl -i -X POST http://localhost:3000/arguments.json \
      -d 'title=Arg to Delete' \
      -d 'premises=First premise.' \
      -d 'premises=Second premise.' \
      -d 'conclusion=The conclusion! :D' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 372
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "url": "/tester/arg-to-delete",
      "message": "Created a new argument!",
      "argument": {
        "title": "Arg to Delete",
        "premises": [
          "First premise.",
          "Second premise."
        ],
        "conclusion": "The conclusion! :D",
        "object_type": "argument",
        "sha1": "7a8c9ebb4406688054bde7f3d2f8ec64ddf2e883",
        "repo": "arg-to-delete"
      },
      "error": null
    }

    # DELETE /:name/:repo.json
    curl -i -X DELETE http://localhost:3000/tester/arg-to-delete.json \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 86
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "url": "/",
      "message": "Deleted repo 'tester/arg-to-delete'.",
      "error": null
    }

-->

# Session Routes (Authenticated)

<a name="join"></a>
## Join [&para;](#join)

<a name="post-users"></a>
### POST /users.json

*Create a new user account.*

#### Params

+ username: (Required) The new user's username.
+ password: (Required) The new user's password.
+ email: (Required) The new user's email.

#### Returns

+ Success: 201 (Created)
+ Error: 400 (Bad Request)
+ Error: 409 (Resource Conflict)

#### Example

    curl -i -X POST http://localhost:3000/users.json \
      -d 'username=tester' \
      -d 'password=tester12' \
      -d 'email=tester@xyz.com' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 221
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tester",
      "message": "Welcome aboard, tester!",
      "user": {
        "username": "tester",
        "join_date": "2013-08-12T13:52:38.210Z",
        "gravatar_id": "cf3321b32988beb65273932bf8de619e"
      },
      "error": null
    }

<a name="login"></a>
## Login [&para;](#login)

<a name="post-login"></a>
### POST /login.json

*Start an authenticated user session.*

#### Params

+ username: The user's username.
+ password: The user's password.

#### Returns

+ Success: 200 (OK)
+ Error: 401 (Unauthorized)

#### Example

    curl -i -X POST http://localhost:3000/login.json \
        -d 'username=tester' \
        -d 'password=tester12' \
        -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 76
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "url": "/tester",
      "message": "Welcome back, tester",
      "error": null
    }

<a name="get-logout"></a>
### GET /logout.json

*End the current user session.*

#### Params

*No params.*

#### Returns

+ Success: 200 (OK)

#### Example

    curl -i http://localhost:3000/logout.json \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 74
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22%22%7D.AJY%2Fn4IAE2DtwZfmTqqyhynLvqswFNU3sUzlQ0uCPQqZNWHvHZaOBzcAm5e7ZTbbOSDiPUDpiq4ibWFyTb49ww; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "url": "/",
      "message": "Logged out successfully.",
      "error": null
    }

<a name="publish"></a>
## Publish [&para;](#publish)

<a name="post-arguments"></a>
### POST /arguments.json

*Create a new argument (with repo).*

#### Params

+ title: [Required] The argument title. (100 characters max)
+ premises: [Required] The argument premises. (240 chars max, for each)
+ conclusion: [Required] The argument conclusion. (240 chars max)

#### Returns

+ Success: 201 (Created)
+ Error: 400 (Bad Request)
+ Error: 401 (Unauthorized)

#### Example

    curl -i -X POST http://localhost:3000/arguments.json \
      -d 'title=My Argument ^_^' \
      -d 'premises=First premise.' \
      -d 'premises=Second premise.' \
      -d 'conclusion=The conclusion! :D' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 378
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tester/my-argument-^_^",
      "message": "Created a new argument!",
      "argument": {
        "title": "My Argument ^_^",
        "premises": [
          "First premise.",
          "Second premise."
        ],
        "conclusion": "The conclusion! :D",
        "object_type": "argument",
        "sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
        "repo": "my-argument-^_^"
      },
      "error": null
    }

<a name="post-tags"></a>
### POST /tags.json

*Create a new tag (support, dispute, citation, or commentary).*

#### Params

Required for **all** tag types:

+ tag_type: The tag's type: 'support', 'dispute', 'citation', or 'commentary'.
+ target_type: The target's type: 'argument' or 'proposition'.
+ target_sha1: The target's sha1.

Required for **support and dispute** tags:

+ source_type: The source's type: 'argument' or 'proposition'.
+ source_sha1: The source's sha1.

Required for **citation** tags:

+ citation_text: The citation text, which may include urls. (240 chars max)

Required for **commentary** tags:

+ commentary_text: The commentary text. (2400 chars max)

#### Returns

+ Success: 201 (Created)
+ Error: 400 (Bad Request)
+ Error: 401 (Unauthorized)

#### Example: Create a Citation Tag

    curl -i -X POST http://localhost:3000/tags.json \
      -d 'tag_type=citation' \
      -d 'target_type=proposition' \
      -d 'target_sha1=30be8f3b68d20f5c3898265e33c583ddee374a6a' \
      -d 'citation_text=The citation text, with url: http://wikipedia.org/wiki/Citation' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 423
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tags/412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae",
      "message": "Created a new tag!",
      "tag": {
        "object_type": "tag",
        "tag_type": "citation",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
        "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
      },
      "error": null
    }

#### Example: Create a Support Tag

    curl -i -X POST http://localhost:3000/tags.json \
      -d 'tag_type=support' \
      -d 'target_type=proposition' \
      -d 'target_sha1=30be8f3b68d20f5c3898265e33c583ddee374a6a' \
      -d 'source_type=proposition' \
      -d 'source_sha1=dfe2394f3cdad27e56023cd0574be36b9a5f9e6e' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 431
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:38 GMT
    Connection: keep-alive

    {
      "url": "/tags/08f6c25476af45f8d8ee4cb0601740bc7bf098ab",
      "message": "Created a new tag!",
      "tag": {
        "object_type": "tag",
        "tag_type": "support",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "source_type": "proposition",
        "source_sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e",
        "sha1": "08f6c25476af45f8d8ee4cb0601740bc7bf098ab"
      },
      "error": null
    }

<a name="delete"></a>
## Delete [&para;](#delete)

<a name="delete-repo"></a>
### DELETE /:name/:repo.json

*Delete a repo.*

#### Notes

Users may only delete their own repos.

#### Params

+ name: The repo owner's username.
+ repo: The repo name.

#### Returns

+ Success: 200 (OK)
+ Error: 401 (Unauthorized)
+ Error: 403 (Forbidden)

#### Example

    curl -i -X DELETE http://localhost:3000/tester/arg-to-delete.json \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 200 OK

    X-Powered-By: Express
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET,PUT,POST
    Access-Control-Allow-Headers: Content-Type, Authorization
    Content-Type: application/json
    Content-Length: 86
    Set-Cookie: connect.sess=s%3Aj%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.0bdDTiafhwxCfkA%2BJQumBL17tYkebS5qSQgpuopgH2Kbgv%2B5IjfP6W2h12P4iS0ptBn2oYgOM02djfmZr8jSpA; Path=/; HttpOnly
    Date: Mon, 12 Aug 2013 13:52:39 GMT
    Connection: keep-alive

    {
      "url": "/",
      "message": "Deleted repo 'tester/arg-to-delete'.",
      "error": null
    }

<a name="changes"></a>
# Changes

## 0.1.0

Add Search route.

## 0.0.1alpha6

Add route to delete a repo.

## 0.0.1alpha5

Include original commit with argument.

## 0.0.1alpha4

Include metadata with each proposition.

## 0.0.1alpha3

Include metadata with argument propositions.

## 0.0.1alpha2

Add Proposition routes.

## 0.0.1alpha1

Initial version with routes for Users, Repos, Arguments, Propositions, and Tags.
