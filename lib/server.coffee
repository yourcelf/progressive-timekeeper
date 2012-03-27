express = require 'express'

start = (options={port: 8000, host: 'localhost'}) ->
  app = express.createServer()
  app.configure ->
    app.use require('connect-assets')()

  app.configure 'development', ->
    app.use express.static __dirname + '/../static'
    app.use express.errorHandler { dumpExceptions: true, showStack: true }

  app.configure 'production', ->
    app.use express.static __dirname + '/../static', { maxAge: 1000 * 60 * 60 * 24 * 365 }

  app.set 'view engine', 'jade'
  app.set 'view options', layout: false

  #
  # Views
  #
  app.get '/', (req, res) -> res.render 'index', title: "Progressive Clock"

  #
  # Go!
  #
  app.listen options.port

module.exports = { start }
