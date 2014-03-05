{IncomingForm} = require 'formidable'
{createTransport} = require 'nodemailer'

http = require 'http'

config = exports.config =
    listen: {host: 'localhost', port: 8080}
    transport: {name: 'Direct'}
    recipients: {}

smtp = createTransport config.transport.name, config.transport.options

# Load config from a JSON file
exports.loadConfig = (filename) ->
  console.log "Loading config from #{filename}..."
  config = require filename

# HTTP / Connect / Express request handler
exports.handler = (req, res) ->
  form = new IncomingForm()

  form.parse req, (err, fields, files) ->
    # Get the recipient config
    recipient = config.recipients[fields.recipient]

    if not recipient
      res.writeHead 400, 'content-type': 'text/plain'
      return res.end "Invalid recipient #{fields.recipient}"

    # Send the mail
    console.log "#{fields.from} -> #{recipient.to}"
    console.log "Message: #{fields.message}"

    options =
      from: fields.from
      replyTo: fields.from
      to: recipient.to
      subject: fields.title or recipient.title

    # Only attach files if allowed
    if recipient.allowFiles
      attachments = (fileName: f.name, filePath: f.path for f in files)
      options.attachments = attachments

    # Send mail to recipients
    smtp.sendMail options, (err, response) ->
      if err
        res.writeHead 500, 'content-type': 'text/plain'
        return res.end err.toString()

      res.writeHead 200, 'content-type': 'text/plain'
      res.end 'Successfully sent email'

# Create an HTTP server and listen for POST requests
exports.runServer = ->
  app = http.createServer (req, res) ->
    if req.url is '/' and req.method.toLowerCase() is 'post'
      exports.handler req, res

  app.listen config.listen.port, config.listen.host, ->
    console.log "Lisenting on #{config.listen.host}:#{config.listen.port}"

if require.main is module
  if process.argv.length > 2
    exports.loadConfig require('path').resolve(process.argv[2])

  exports.runServer()
