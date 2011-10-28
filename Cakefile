fs = require 'fs'
jsmin = require 'jsmin'
{exec} = require 'child_process'

handle_errors = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr

files = [
  'dudlpad'
]

task 'build', 'Create compiled JS output', ->
  console.log 'build her a cake or something...'
  exec 'rm -rf lib/*.js docs', handle_errors
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

    for file in files
      do (file) ->
        fs.readFile "lib/#{file}.js", 'utf8', (err, data) ->
          throw err if err
          mindata = jsmin.jsmin data
          fs.writeFile "lib/#{file}.min.js", mindata, (err) ->
            throw err if err
  exec 'docco src/*.coffee'

task 'deploy', 'Deploy live test and docco docs to GitHub', ->
  exec 'sh deploy.sh', handle_errors

task 'clean', ->
  exec 'rm -rf lib/*.js docs', handle_errors
