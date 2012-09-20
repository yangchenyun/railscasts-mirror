# Goal
A downloader / parser to fetch videos with meta data from railscasts.com with support for pro accout.

## Work-in-progress
- finish the job queue with `kue`
- write a server with `express`

## Why
The speed within domestic China is too slow for smooth streaming from railscasts.com, so I decided to create a parser/downloader to fetch the videos all at once with their individual meta data.

You could 
## Components
`superagent` is used to setup cookie token to access my professional account and send request.

`jsdom` is used to parse the HTML file and fetch meta data.

`kue` is used to store and process download tasks in a job queue.

`express` is used to simulate a simple web server.

## Usage
Setup `$RC_TOKEN` to hold your login token which will be used to login your professional account.
