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
  exec 'mkdir tmp', handle_errors
  exec 'cp -r live_test.html docs lib tmp/.', handle_errors
  exec 'git checkout gh-pages', handle_errors
  exec 'mv tmp/* .', handle_errors
  exec 'rm -rf tmp', handle_errors
  exec 'git commit -am "auto-deployed to GitHub"', handle_errors
  exec 'git checkout master', handle_errors

task 'clean', ->
  exec 'rm -rf lib/*.js docs', handle_errors
