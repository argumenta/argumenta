# Argumenta instance, User, Storage and Errors classes
argumenta = require '../app/argumenta'
Argument  = require '../lib/argumenta/objects/argument'
Storage   = require '../lib/argumenta/storage'
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
    return res.notFound "Repo '#{name}/#{repo}' not found." if err

    repo = repos[0]
    return res.reply 'users/repo'
      user: repo.user
      repo: repo.reponame
      commit: repo.commit
      argument: repo.target
