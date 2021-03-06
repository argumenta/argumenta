express    = require 'express'
flash      = require 'connect-flash'
http       = require 'http'
_          = require 'underscore'
pkg        = require '../package.json'
middleware = require '../app/middleware'
helpers    = require '../app/helpers'
routes     = require '../routes'
config     = require '../config'
Objects    = require '../lib/argumenta/objects'

# Express Instance
app = module.exports = express()

# Config
configure = () ->
  app.configure ->
    app.enable 'trust proxy' if config.proxy
    app.set 'views', __dirname + '/../views'
    app.set 'view engine', 'jade'
    app.set 'view options', {layout: false}
    gzipDirs = /^\/(images|stylesheets|javascripts|widgets)/
    app.use middleware.gzipped gzipDirs if config.gzip
    app.use middleware.cors( origin: "*", methods: "GET,PUT,POST" )
    app.use express.favicon(__dirname + '/../public/images/favicon.ico')
    app.use express.static(__dirname + '/../public')
    app.use express.bodyParser()
    app.use express.cookieParser( config.appSecret )
    app.use express.methodOverride()
    app.use express.cookieSession
      key: 'session'
      cookie: { path: '/', httpOnly: false, maxAge: null }
    app.use flash()
    app.use middleware.globals
      baseUrl:  config.baseUrl,
      siteName: config.siteName,
      title:    ''
    app.use middleware.locals (req, res) ->
      return extensions =
        username: req.session.username or ''
        errors:   req.flash 'errors'
        messages: req.flash 'messages'
    app.locals.pretty = true
    app.set 'json spaces', '  '
    app.use middleware.reply
      processor: (opts, req) ->
        format = req.param 'format'
        # Send argumenta objects with data() methods as plain object data
        if format is 'json' or format is 'jsonp'
          opts = helpers.data(opts)
        return opts
    app.use middleware.success()
    app.use middleware.failed()
    app.use middleware.created()
    app.use middleware.notFound view: 'index'
    app.use app.router

app.configure 'production', ->
  app.use express.logger()
  configure()

app.configure 'testing', ->
  configure()

app.configure 'development', ->
  app.use express.logger('dev')
  cssDir = __dirname + '/../public'
  helpers.watchCSS app, cssDir
  configure()
  app.use express.errorHandler()

# Fallback config
unless config.appMode.match /production|testing|development/
  console.log "Using generic configure for app mode: '#{config.appMode}'"
  configure()

# Routes
app.get  '/.:format?',                                     routes.main.index

app.get  '/users',                                         routes.users.index
app.post '/users.:format?',                                routes.users.create
app.get  '/users/:name.:format?',                          routes.users.show

app.get  '/join',                                          routes.join.index

app.get  '/login',                                         routes.login.index
app.post '/login.:format?',                                routes.login.verify
app.get  '/logout.:format?',                               routes.logout.index

app.get  '/arguments/new',                                 routes.arguments.new
app.post '/arguments.:format?',                            routes.arguments.create
app.get  '/arguments/:hash.:format?',                      routes.arguments.show
app.get  '/arguments/:hash/edit',                          routes.arguments.edit
app.get  '/arguments/:hash/propositions.:format?',         routes.arguments.propositions
app.get  '/arguments/:hash/discussions.:format?',          routes.arguments.discussions

app.get  '/propositions/new',                              routes.propositions.new
app.post '/propositions.:format?',                         routes.propositions.create
app.get  '/propositions/:hash.:format?',                   routes.propositions.show
app.get  '/propositions/:hash/tags.:format?',              routes.propositions.tags
app.get  '/propositions/:hash/tags-plus-sources.:format?', routes.propositions.tagsPlusSources

app.get  '/search/:query?.:format?',                       routes.search.query

app.get  '/tags/:hash.:format?',                           routes.tags.show
app.post '/tags.:format?',                                 routes.tags.create

app.get  '/discussions/:id.:format?',                      routes.discussions.show
app.post '/discussions.:format?',                          routes.discussions.create

app.get  '/comments/:id.:format?',                         routes.comments.show
app.post '/comments.:format?',                             routes.comments.create

app.get  '/:name.:format?',                                routes.users.public
app.get  '/:name/:repo.:format?',                          routes.repos.show
app.delete '/:name/:repo.:format?',                        routes.repos.delete

# Http
http.createServer(app).listen(config.port)

# Exceptions
process.on 'uncaughtException', (err) ->
  date = new Date()
  timestamp = '[' + date.toISOString().slice(0, -5) + ']'
  console.error timestamp, "Uncaught exception: " + err
  process.exit() unless config.appMode is 'testing'

version = pkg.version
mode    = config.appMode
port    = config.port

console.log "Argumenta #{version} (#{mode} mode) | http://localhost:#{port}"
