# Single page parse will:
# 1. Fetch information about each episode into a JSON object
# 2. Add the episode into videos into a queue if it isnt downloaded
# 3. If everything goes well, report back to index page parser

require 'coffee-script'
fs = require 'fs'
jsdom = require 'jsdom'
request = require 'superagent'
jquery = fs.readFileSync("./jquery-1.7.2.min.js", 'utf8').toString()
COOKIE = 'token=m3XJHXak3AdZUi71ohexww'
ASSET = /\d+-(.+)\.(png|jpg|jpeg|gif|zip|mp4|m4v|webm|ogv)/

getAssetName = (path) ->
  index = path.search ASSET
  path.substring index

# The single page parser
module.exports = exports = (host, path) ->

  console.log "begin processing #{path}"

  request
    .get(host + path)
    .set('Cookie', COOKIE)
    .end (res) ->
      jsdom.env
        html: res.text
        src: [jquery]
        done: (err, window) ->
          $ = window.$

          # Parse the page with jQuery
          sequence = Number $('.position').text().slice(1)
          title = $('.position').parent('h1').text().replace(/^[#\d]+ /,'')

          details = $('.details').text().split(/\s+\|\s+/)

          date = new Date details[0]
          length = details[1]
          tags = details[2].split(/\s*,\s*/)

          description = $('.description').text()

          noteHtml = $('.show_notes').html()

          # fetch the screenshot name and add to download queue
          screenshotPath = $('.screenshot img').attr('src')
          screenshot = getAssetName screenshotPath

          # add_to_queue (url, dst_dir)
          # add_to_queue (host + screenshotPath), 'screenshots'


          videoPath = ''
          sourcePath = ''

          links = $('ul.downloads a')

          links.each (index, link) ->

            switch  $(link).text()
              when 'source code' then sourcePath = link.href
              when 'mp4' then videoPath = link.href


          # add_to_queue (host + sourcePath), 'source-codes'
          # add_to_queue (host + videoPath), 'videos'

          video = getAssetName videoPath
          source = getAssetName sourcePath

          console.log { sequence, title, date, length, tags, description, noteHtml, screenshot, video, source }
          console.log "finish processing #{path}"
