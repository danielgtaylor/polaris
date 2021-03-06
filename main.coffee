{IncomingForm} = require 'formidable'
{createTransport} = require 'nodemailer'

http = require 'http'
util = require 'util'

polaris = module.exports

polaris.config =
    listen: {host: 'localhost', port: 8080}
    transport: {name: 'Direct'}
    recipients: {}

smtp = null

# Load config from a JSON file
polaris.loadConfig = (filename) ->
  console.log "Loading config from #{filename}..."
  polaris.config = require filename

# HTTP / Connect / Express request handler
polaris.handler = (req, res) ->
  form = new IncomingForm()

  if not smtp
    transportConfig = polaris.config.transport
    smtp = createTransport transportConfig.name, transportConfig.options

  form.parse req, (err, fields, files) ->
    # Get the recipient config
    recipient = polaris.config.recipients[fields.recipient]

    if not recipient or not fields.from or not fields.message
      res.writeHead 400, 'content-type': 'text/plain'
      return res.end "Bad recipient or missing required parameters:\n" +
                     util.inspect fields

    if fields.name
      fields.from = "#{fields.name} <#{fields.from}>"

    for field in ['phone', 'location']
      if fields[field]
        fields.message = "#{field}: #{fields[field]}\n\n#{fields.message}"

    # Send the mail
    console.log "#{fields.from} -> #{recipient.to}"
    console.log "Message: #{fields.message}"

    options =
      from: fields.from
      replyTo: fields.from
      to: recipient.to
      subject: fields.title or recipient.title or 'Email form'
      text: fields.message

    # Only attach files if allowed
    if files and recipient.allowFiles
      options.attachments = []
      for name, file of files
        options.attachments.push fileName: file.name, filePath: file.path

    # Send mail to recipients
    smtp.sendMail options, (err, response) ->
      if err
        res.writeHead 500, 'content-type': 'text/plain'
        return res.end err.toString()

      res.writeHead 302, location: recipient.redirect
      res.end()

# Create an HTTP server and listen for POST requests
polaris.runServer = (done) ->
  app = http.createServer (req, res) ->
    # Enable CORS
    res.setHeader "Access-Control-Allow-Origin", "*"
    res.setHeader "Access-Control-Allow-Headers", "X-Requested-With"

    # Handle requests
    if req.url is '/' and req.method.toLowerCase() is 'post'
      polaris.handler req, res

  listenConfig = polaris.config.listen
  app.listen listenConfig.port, listenConfig.host, ->
    console.log "Listening on #{polaris.config.listen.host}:" +
                "#{polaris.config.listen.port}"
    done? null, app

if require.main is module
  if process.argv.length > 2
    polaris.loadConfig require('path').resolve(process.argv[2])

  polaris.runServer()
