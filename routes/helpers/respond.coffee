config = require '../../config'
_      = require 'underscore'

# Respond helper: serves on success or error, as html or json
respond = ( view, opts, req, res ) ->
  opts     = opts         or {}
  status   = opts.status  or (if opts.error then 400 else 200)
  error    = opts.error   or null
  message  = opts.message or null
  headers  = opts.headers or null
  format   = req.param('format') or 'html'

  # Set the status
  res.status status

  # Set any headers
  res.set key, val for key, val of headers if headers

  # Creates json object from opts, without the http info
  jsonFor = (opts) ->
    json = _.extend {}, opts, {error}
    delete json.headers
    delete json.status
    return json

  switch format
    when 'html'
      # Prepare any messages or errors
      errors = res.locals.errors or []
      messages = res.locals.messages or []
      if error then errors.push error
      if message then messages.push message
      # Render the view
      viewOpts = _.extend {}, opts, {errors, messages, headers}
      res.render view, viewOpts
    when 'json'
      res.set 'Content-Type', 'application/json'
      res.json jsonFor opts
    when 'jsonp'
      json = jsonFor opts
      cb = req.query.callback or 'jsonpCallback'
      jsonp = cb + '(' + JSON.stringify( json, null, '  ' ) + ');'
      res.set 'Content-Type', 'text/javascript'
      res.send jsonp

module.exports = respond
