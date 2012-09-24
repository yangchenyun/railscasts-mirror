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
LAST_PAGE = 43
results = []

writeData = ->
  fs.writeFile "./data.json", JSON.stringify(results, null, ' '), (err) ->
    if err
      console.log err
    else
      console.log "results are saves to data.json"

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

          # FIXME use promises to rewrite this part
          expectCall = episodes.length
          actualCall = 0

          episodes.each (index, epi) ->
            # fetch the path
            path = $('.watch a', epi).attr('href').replace(/\?.+$/,'')

            # deligate the parsing task to single page parsing
            # store the result
            parsePage HOST, path, (data) ->
              # add result for after each parsing
              results.push data
              actualCall++

              # detect the end and write data to file
              writeData() if page is LAST_PAGE && expectCall is actualCall

          if page <= LAST_PAGE
            # recursively fetch other pages after 30 seconds
            setTimeout ->
             parseIndex url, page + 1
            , 30 * 1000

parseIndex "#{HOST}?page=", 1
