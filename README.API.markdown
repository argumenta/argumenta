
# Argumenta API

## [Overview](#overview) / [Features](#features) / [Routes](#routes) / [Usage](#usage)

<span id="overview"></span>
## Overview

The Argumenta API provides a RESTful interface to data in JSON form.

It can be used to access resources including Users, Repos, Arguments, and Tags.  
Planned resources include Propositions, Follows, Activity, and Search.

<span id="features"></span>
## Features

The current version (0.0.1alpha1) provides the following features:

+ Read access for general use by unauthenticated clients.
+ Cookie-based authenticated sessions for account creation, login, and publishing.
+ JSON and JSONP response formats via the extensions '.json' and '.jsonp'.

<span id="routes"></span>
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

<span id="usage"></span>
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

    $ curl -i 'http://localhost:3000/users/tester.jsonp'

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: text/javascript
    Content-Length: 94
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
    Connection: keep-alive

    jsonpCallback({
      "user": {
        "username": "tester",
        "repos": []
      },
      "error": null
    });

Note the response is padded with a call to our default callback, `jsonpCallback()`.

#### Example: JSONP Request with a Custom Callback Name

You can change the callback name by adding a `callback` parameter to the url.

Here we set the callback to `myCb` by adding `?callback=myCb`:

    $ curl -i 'http://localhost:3000/users/tester.jsonp?callback=myCb'

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: text/javascript
    Content-Length: 85
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
    Connection: keep-alive

    myCb({
      "user": {
        "username": "tester",
        "repos": []
      },
      "error": null
    });

<span id="users"></span>
## Users [&para;](#users)

<span id="get-users-user"></span>
### GET /users/:user.json

*Get a user's account info.*

#### Params

+ user: The user's username.

#### Example

    curl -i localhost:3000/users/tester.json

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 151
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
    Connection: keep-alive

    {
      "user": {
        "username": "tester",
        "repos": {
          "my-argument-^_^": "96e8c6b1696be8639942f9153f3c9af473af6dd0"
        }
      },
      "error": null
    }


<span id="get-user"></span>
### GET /:user.json

*Get a user's account and argument repos.*

### Params

+ user: The user's username.

### Example

    curl -i localhost:3000/tester.json

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 960
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
    Connection: keep-alive

    {
      "user": {
        "username": "tester",
        "repos": {
          "my-argument-^_^": "96e8c6b1696be8639942f9153f3c9af473af6dd0"
        }
      },
      "repos": [
        {
          "username": "tester",
          "reponame": "my-argument-^_^",
          "user": {
            "username": "tester",
            "repos": {
              "my-argument-^_^": "96e8c6b1696be8639942f9153f3c9af473af6dd0"
            }
          },
          "commit": {
            "target_type": "argument",
            "target_sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
            "committer": "tester",
            "commit_date": "2012-09-22T08:12:56Z",
            "parent_sha1s": []
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

<span id="repos"></span>
## Repos [&para;](#repos)

<span id="get-user-repo"></span>
### GET /:user/:repo.json

*Get a repo owned by a user.*

#### Params

+ user: The repo owner's username.
+ repo: The repo name.

#### Example

    curl -i http://localhost:3000/tester/my-argument-^_^.json

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 763
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
    Connection: keep-alive

    {
      "repo": {
        "username": "tester",
        "reponame": "my-argument-^_^",
        "user": {
          "username": "tester",
          "repos": {
            "my-argument-^_^": "42e03789efdc8731c1e0e56b59b806d86f79ae0f"
          }
        },
        "commit": {
          "target_type": "argument",
          "target_sha1": "675f1c4a2a2bec4fa1e5b745a4b94322dda294e6",
          "committer": "tester",
          "commit_date": "2012-09-27T10:35:46Z",
          "parent_sha1s": []
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

<span id="arguments"></span>
## Arguments [&para;](#arguments)

<span id="get-argument"></span>
### GET /arguments/:sha1.json

*Get an argument by its sha1.*

#### Params

+ sha1 - The argument's sha1.

#### Example

    curl -i http://localhost:3000/arguments/675f1c4a2a2bec4fa1e5b745a4b9432dda294e6.json

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 302
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
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
      "error": null
    }

<span id="argument-propositions"></span>
## Argument Propositions [&para;](#argument-propositions)

<span id="get-argument-propositions"></span>
### GET /arguments/:sha1/propositions.json

*Get an argument's propositions.*

#### Params

+ sha1 - The argument's sha1.

#### Example

    curl -i http://localhost:3000/arguments/675f1c4a2a2bec4fa1e5b745a4b94322dda294e6/propositions.json

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 745
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%7D.uie4zyZwXs1gm4wy8hoWGGj7yp%2BR4XiEkv%2FIoxw5GoQ; path=/; httpOnly
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
          "sha1": "49cb32b909f2cdfad750fd76af83a126414d0e7a"
        },
        {
          "text": "Second premise.",
          "object_type": "proposition",
          "sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a"
        },
        {
          "text": "The conclusion! :D",
          "object_type": "proposition",
          "sha1": "dfe2394f3cdad27e56023cd0574be36b9a5f9e6e"
        }
      ],
      "error": null
    }

<span id="propositions"></span>
## Propositions [&para;](#propositions)

<span id="get-proposition"></span>
### GET /propositions/:sha1.json

*Get a proposition by its sha1.*

#### Params
#### Returns
#### Example

<span id="get-proposition-tags"></span>
### GET /propositions/:sha1/tags.json

*Get a proposition's tags (plus source objects).*

#### Params
#### Returns
#### Example

<span id="tags"></span>
## Tags [&para;](#tags)

<span id="get-tag"></span>
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
    Content-Type: application/json; charset=utf-8
    Content-Length: 303
    Connection: keep-alive

    {
      "tag": {
        "tag_type": "citation",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
        "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
      },
      "error": null
    }

# Session Routes (Authenticated)

<span id="join"></span>
## Join [&para;](#join)

<span id="post-users"></span>
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
    Content-Type: application/json; charset=utf-8
    Content-Length: 144
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.CZdOaTV%2FBrdAIgvvdt5VFwr5Dc%2Baidjrx38qVAi2E0w; path=/; httpOnly
    Connection: keep-alive

    {
      "url": "/users/tester",
      "message": "Welcome aboard, tester!",
      "user": {
        "username": "tester",
        "repos": []
      },
      "error": null
    }

<span id="login"></span>
## Login [&para;](#login)

<span id="post-login"></span>
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
    Content-Type: application/json; charset=utf-8
    Content-Length: 82
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22tester%22%7D.CZdOaTV%2FBrdAIgvvdt5VFwr5Dc%2Baidjrx38qVAi2E0w; path=/; httpOnly
    Connection: keep-alive

    {
      "url": "/users/tester",
      "message": "Welcome back, tester",
      "error": null
    }

<span id="get-logout"></span>
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
    Content-Type: application/json; charset=utf-8
    Content-Length: 74
    Set-Cookie: connect.sess=j%3A%7B%22flash%22%3A%7B%7D%2C%22username%22%3A%22%22%7D.ukp6vvO3ceC92ca%2Fj2ycrGuAk%2Fd96hoqdQjGU%2FYj%2Fw0; path=/; httpOnly
    Connection: keep-alive

    {
      "url": "/",
      "message": "Logged out successfully.",
      "error": null
    }

<span id="publish"></span>
## Publish [&para;](#publish)

<span id="post-arguments"></span>
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
    Content-Type: application/json; charset=utf-8
    Content-Length: 378
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

<span id="post-tags"></span>
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

#### Example

    curl -i -X POST http://localhost:3000/tags.json \
      -d 'tag_type=citation' \
      -d 'target_type=proposition' \
      -d 'target_sha1=30be8f3b68d20f5c3898265e33c583ddee374a6a' \
      -d 'citation_text=The citation text, with url: http://wikipedia.org/wiki/Citation' \
      -b ~/tmp/cookies -c ~/tmp/cookies

    HTTP/1.1 201 Created
    X-Powered-By: Express
    Content-Type: application/json; charset=utf-8
    Content-Length: 397
    Connection: keep-alive

    {
      "url": "/tags/412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae",
      "message": "Created a new tag!",
      "tag": {
        "tag_type": "citation",
        "target_type": "proposition",
        "target_sha1": "30be8f3b68d20f5c3898265e33c583ddee374a6a",
        "citation_text": "The citation text, with url: http://wikipedia.org/wiki/Citation",
        "sha1": "412cd5f899b6f01685e7f8ab6cbaf0ef00ebb7ae"
      },
      "error": null
    }

