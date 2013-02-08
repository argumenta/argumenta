# Argumenta instance, User, Storage and Errors classes
argumenta = require '../app/argumenta'
Argument  = require '../lib/argumenta/objects/argument'
Errors    = require '../lib/argumenta/errors'

# Set a repo via POST
exports.create = (req, res) ->
  {title, premises, conclusion} = req.body

  unless username = req.session.username
    req.cookies.argument = req.body
    return res.redirect "/login"

  argument = new Argument title, premises, conclusion

  argumenta.arguments.commit username, argument, (err, commit) ->
    if err
      req.flash 'argument', req.body
      return res.reply "arguments/new"
        error: err.message
        status: Errors.statusFor err
    else
      user = req.session.username
      repo = argument.repo()
      return res.redirect "/#{user}/#{repo}"

# Show a repo as html, json, or jsonp
exports.show = (req, res) ->
  name = req.param 'name'
  repo = req.param 'repo'
  unless name? and repo?
    return res.reply 'index', error: "No repo for '/#{name}/#{repo}'."

  key  = [name, repo]
  keys = [key]
  argumenta.storage.getRepos keys, (err, repos) ->
    if err
      return res.failed "/"
        error: err.message
        status: Errors.statusFor err
    if repos.length == 0
      return res.notFound "Repo '#{name}/#{repo}' not found."

    return res.reply 'users/repo'
      repo: repos[0]

# Delete a repo via DELETE
exports.delete = (req, res) ->
  username = req.session.username
  name = req.param 'name'
  repo = req.param 'repo'

  unless username
    return res.failed "/login", "Login to delete repos.",
      status: 401

  unless username is name
    return res.failed "/", "Only the repo owner may delete a repo.",
      status: 403

  argumenta.storage.deleteRepo name, repo, (err) ->
    if err
      return res.failed "/",
        error: err.message,
        status: Errors.statusFor err
    else
      return res.success "/", "Deleted repo '#{name}/#{repo}'."
