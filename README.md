# Goal
A downloader / parser to fetch videos with meta data from railscasts.com with support for pro accout. It does two things:
1. fetch all the video you could access
2. mirror an simple rails-casts server

## Work-in-progress
- write a mirror server with `express`

## Why
The speed within domestic China is too slow for smooth streaming from railscasts.com, so I decided to create a parser/downloader to fetch the videos all at once with their individual meta data.

## Components
`superagent` is used to setup cookie token to access my professional account and send request.

`jsdom` is used to parse the HTML file and fetch meta data.

`kue` is used to store and process download tasks in a job queue.

`express` is used to simulate a simple web server.

## Usage
Setup `$RC_TOKEN` to hold your login token which will be used to login your professional account.

`export RC_TOKEN=your_token_at_rails_cats`

Install dependencies with:
`npm install`

Need to have redis server installed to use `kue`, communicate with the app through the `$REDISTOGO_URL` variable in the format `redis://redis:<password>@<host>:<port>`.

`npm run fetch` to start to fetch to all assets url.

`npm run process` to start download all assets.
