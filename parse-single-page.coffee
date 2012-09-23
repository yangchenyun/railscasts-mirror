# Single page parse will:
# 1. Fetch information about each episode into a JSON object
# 2. Add the episode into videos into a queue if it isnt downloaded
# 3. If everything goes well, report back to index page parser

require 'coffee-script'
fs = require 'fs'
jsdom = require 'jsdom'
request = require 'superagent'
jobs = require('./job-init').jobs
jquery = fs.readFileSync("./jquery-1.7.2.min.js", 'utf8').toString()
COOKIE = "token=#{process.env.RC_TOKEN}"
ASSET = /\d+-(.+)\.(png|jpg|jpeg|gif|zip|mp4|m4v|webm|ogv)/

getAssetName = (path) ->
  index = path.search ASSET
  path.substring index

addToJob = (url, dir, opts) ->
  return unless url
  opts ||= priority: normal, attempts: 5
  type = url.match(/\.(\w+?)$/)[1]
  job = jobs.create type,
    title: "downloading #{url}"
    url: url
    dir : dir
  .priority(opts.priority)
  .attempts(opts.attempts)
  .save()

  job
    .on 'complete', ->
      console.log "Job complete"
    .on 'failed', ->
      console.log 'Job failed'
    .on 'progress', (progress) ->
      process.stdout.write "job #{job.id} #{progress}% complete"

# The single page parser
module.exports = exports = (host, path, callback) ->

  console.log "begin parsing #{path}"

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

          addToJob(host + screenshotPath, 'screenshot', priority : 'high', attempts : 2)

          videoPath = ''
          sourcePath = ''

          links = $('ul.downloads a')

          links.each (index, link) ->

            switch  $(link).text()
              when 'source code' then sourcePath = link.href
              when 'mp4' then videoPath = link.href


          addToJob(sourcePath, 'source-code', priority : 'normal', attempts : 2)
          addToJob(videoPath, 'video', priority : 'low', attempts : 10)

          video = getAssetName videoPath
          source = getAssetName sourcePath

          console.log "finish parsing #{path}"
          callback { sequence, title, date, length, tags, description, noteHtml, screenshot, video, source }
