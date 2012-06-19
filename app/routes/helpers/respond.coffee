config = require '../../../config'
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
      # Create json object from opts, without the http info
      json = _.extend {}, opts, {error}
      delete json.headers
      delete json.status
      # Serve json
      res.json json

module.exports = respond
