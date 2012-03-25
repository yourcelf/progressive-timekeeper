option '-p', '--port [8000]', 'port the server runs on'
option '-h', '--host [localhost]', 'base server name'

task 'runserver', 'Run the server, watching for changes.', (options) ->
  server = require './lib/server'
  server.start
    host: options.host or "localhost"
    port: options.port or 8000

task 'test', 'Run tests', (options) ->
  console.log "TODO"
