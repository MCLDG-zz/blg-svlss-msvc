var util  = require('util');
var express  = require('express');
var https = require('https');
var app      = express();
var httpProxy = require('http-proxy');
var fs       = require('fs');

app.use(express.static('public'));

var bookings_api = '';
var airmiles_api = '';

if (process.env.BOOKINGS_API_URL) {
    bookings_api = process.env.BOOKINGS_API_URL
    console.log("from ENV - Bookings API Endpoint: " + bookings_api);
}
if (process.env.AIRMILES_API_URL) {
    airmiles_api = process.env.AIRMILES_API_URL
    console.log("from ENV - Airmiles API Endpoint: " + airmiles_api);
}

var bookings_api_proxy = httpProxy.createProxyServer({
  target: bookings_api, 
  agent: https.globalAgent,
  xfwd: true,
  headers: {
    host: bookings_api.replace(/^https:\/\//, "")
  }
});
var airmiles_api_proxy = httpProxy.createProxyServer({
  target: airmiles_api, 
  agent: https.globalAgent,
  xfwd:  true,
  headers: {
    host: airmiles_api.replace(/^https:\/\//, "")
  }
});
airmiles_api_proxy.on('error', function (err, req, res) {
    res.writeHead(500, {
          'Content-Type': 'text/plain'
              });

      res.end('Something went wrong. And we are reporting a custom error message.');
});

app.all("/bookings", function(req, res) {
    req.url = "/Prod" + req.url;
    console.log("Requesting: " + req.url);
    bookings_api_proxy.web(req, res, {target: bookings_api});
});

app.all("/bookings/*", function(req, res) {
    req.url = "/Prod" + req.url;
    console.log("Requesting: " + req.url);
    bookings_api_proxy.web(req, res, {target: bookings_api});
});

app.all("/airmiles", function(req, res) {
  req.url = "/Prod" + req.url;
  console.log("Requesting: " + req.url);
  airmiles_api_proxy.web(req, res, {target: airmiles_api});
});

app.all("/airmiles/*", function(req, res) {
  req.url = "/Prod" + req.url;
  console.log("Requesting: " + req.url);
  airmiles_api_proxy.web(req, res, {target: airmiles_api});
});

app.listen(process.env.PORT);
console.log('listening on port: ', process.env.PORT)
