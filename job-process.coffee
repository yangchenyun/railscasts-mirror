{kue, jobs} = require('./job-init')
Job = kue.Job
exec = require('child_process').exec

downloadAsset = (file_url, dir, callback) ->
    fileName = require('url').parse(file_url).pathname.split('/').pop()
    console.log "start downloading #{fileName} to #{dir}"
    wget = "wget -P #{dir} #{file_url}"

    child = exec wget, (err, stdout, stderr) ->
      throw err if err
      console.log "#{fileName} downloaded to #{dir}"

    child.on 'exit', (code) ->
      callback()

jobs.process 'zip', 1, (job, done) ->
  {url, dir} = job.data
  downloadAsset(url, dir, done)

kue.app.set 'title', 'Rails Cast Download'
kue.app.listen 2983
console.log 'kue app listening on 2983'
