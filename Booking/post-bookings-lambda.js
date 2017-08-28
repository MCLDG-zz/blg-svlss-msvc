'use strict';

console.log('Loading function');

const doc = require('dynamodb-doc');

const dynamo = new doc.DynamoDB();
var AWS = require("aws-sdk");
var docClient = new AWS.DynamoDB.DocumentClient();
var BOOKING_SNS_ARN = process.env.BOOKING_SNS_ARN;
var BOOKING_TABLE_NAME = process.env.BOOKING_TABLE_NAME;

function randomString(length, chars) {
  var result = '';
  for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
  return result;
}
exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  var body = JSON.parse(event.body);
  var first_name = body.first_name;
  var last_name = body.last_name;
  var from_airport = body.from_airport;
  var to_airport = body.to_airport;
  var departure_date = body.departure_date;
  var return_date = body.return_date;
  var age_group = body.age_group;
  var booking_class = body.booking_class;
  var booking_number = randomString(8, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');

  var params = {
    TableName:BOOKING_TABLE_NAME,
              Item:{
                "booking_number": booking_number,
                "age_group": age_group,
                "first_name": first_name,
                "last_name": last_name,
                "from_airport": from_airport,
                "to_airport" :to_airport,
                "departure_date": departure_date,
                "return_date":return_date,
                "booking_class":booking_class
              }
    };

  console.log(params);
  docClient.put(params, function(err, data) {
      if (err) {
        console.error('Unable to add item. Error JSON:', JSON.stringify(err, null, 2));
      } else {
        console.log('Added item:', JSON.stringify(data, null, 2));

        // POST SNS to TOPIC
        if(/^arn:/.test(BOOKING_SNS_ARN)){
          var sns = new AWS.SNS();
          var params = {
            Message: JSON.stringify({
              booking_number: booking_number,
              from_airport: from_airport,
              to_airport: to_airport,
              departure_date: departure_date
            }, null, 2),
            TopicArn: BOOKING_SNS_ARN
          };
          sns.publish(params, function(err, data) {
            if (err) console.log(err, err.stack); 
            else     console.log(data);
          });
        }
        done(false, booking_number);
      }
      });    

  const done = (err, res) => callback(null, {
    statusCode: err ? '400' : '200',
    body: err ? err.message : JSON.stringify(res),
    headers: {
      'Content-Type': 'application/json',
    },
  });
};
