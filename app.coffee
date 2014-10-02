unless process.env.SENDGRID_USERNAME and process.env.SENDGRID_PASSWORD and process.env.KEY
	console.error "This application require Sendgrid and KEY set"
	process.exit 1

KEY = process.env.KEY

nodemailer = require "nodemailer"
mailTransport = nodemailer.createTransport "SMTP",
	host: 'smtp.sendgrid.net'
	port: 587
	auth:
		user: process.env.SENDGRID_USERNAME
		pass: process.env.SENDGRID_PASSWORD

sendMail = (to, html, callback) ->
	mailTransport.sendMail
		# from: "email-send-test-app <no-reply@non-existent.com>"
		to: to
		subject: "email-send-test-app test letter"
		html: html
		forceEmbeddedImages: yes
	, callback

express = require 'express'
app = express()
	
app.set 'port', process.env.PORT or 3000

logger = require('morgan')
app.use logger ':remote-addr - - [:date] ":method :req[Host] :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent"'

app.use require('method-override')()
app.use require('body-parser').urlencoded extended: on
app.use express.static "#{__dirname}/public"

app.post '/send', (req, res, next) ->
	if req.body.key and req.body.key is KEY
		sendMail req.body.to, req.body.html, (err, result) ->
			# return next err if err
			if err
				console.log err
				res.send 'error'
			else
				res.send 'ok'
	else res.send 'fuck you'

if 'development' is app.get('env')
	app.use require('errorhandler')()
	app.locals.pretty = yes # for Express 3

app.listen app.get('port'), ->
	console.log "Express server listening on port #{app.get('port')}"
