'use strict';

console.log('Loading function');

const doc = require('dynamodb-doc');

const dynamo = new doc.DynamoDB();
var AWS = require("aws-sdk");
var docClient = new AWS.DynamoDB.DocumentClient();
var BOOKING_TABLE_NAME = process.env.BOOKING_TABLE_NAME;

function randomString(length, chars) {
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}
exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    var bookings = [];
    var params = {
      TableName:BOOKING_TABLE_NAME
    };

    function onScan(err, data) {
      if (err) {
        console.error('Unable to scan items. Error JSON:', JSON.stringify(err, null, 2));
      } else {
        console.log('Got item:', JSON.stringify(data, null, 2));
        bookings.push.apply(bookings, data.Items);
        if (typeof data.LastEvaluatedKey != "undefined") {
          console.log("Scanning for more...");
          params.ExclusiveStartKey = data.LastEvaluatedKey;
          docClient.scan(params, onScan);
        }
        console.log('Bookings', JSON.stringify(bookings, null, 2));
        done(false, bookings);
      }
    }

    console.log(params);
    docClient.scan(params, onScan);
    const done = (err, res) => callback(null, {
        statusCode: err ? '400' : '200',
        body: err ? err.message : JSON.stringify({data: res}),
        headers: {
            'Content-Type': 'application/json',
        },
    });
    
};

