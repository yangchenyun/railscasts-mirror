# Index page parser will:
# 1. login with my cookie
# 2. solves pagination
# 3. deligate tasks to signal page parser
# 4. if signle parser is successful, append the JSON object and save them on OS

require 'coffee-script'
fs = require 'fs'
jsdom = require 'jsdom'
request = require 'superagent'
parsePage = require './parse-single-page'

jquery = fs.readFileSync("./jquery-1.7.2.min.js", 'utf8').toString()
HOST = 'http://railscasts.com'
COOKIE = "token=#{process.env.RC_TOKEN}"
results = []

parseIndex = (url, page) ->
  request
    .get(url + page)
    .set('Cookie', COOKIE)
    .end (res) ->
      jsdom.env
        html: res.text
        src: [jquery]
        done: (err, window) ->
          $ = window.$
          # Parse the page with jQuery
          episodes = $('.episode')
          episodes.each (index, epi) ->
            # fetch the path
            path = $('.watch a', epi).attr('href').replace(/\?.+$/,'')

            # deligate the parsing task to single page parsing
            # store the result
            parsePage HOST, path, (data) ->
              results.push data

          if page <= 43
            # recursively fetch other pages
            parseIndex url, page + 1

          else
            # the end and write data to file
            fs.writeFile "./data.json", JSON.stringify(results), (err) ->
              if err
                console.log err
              else
                console.log "results are saves to data.json"

parseIndex "#{HOST}?page=", 1
