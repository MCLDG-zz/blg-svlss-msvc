#!/usr/bin/env python

# Copyright 2016 Amazon.com, Inc. or its affiliates.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

from __future__ import print_function
import boto3
import json
import os
import random
import string

print('Loading function')
BOOKING_SNS_ARN = os.environ['BOOKING_SNS_ARN']
BOOKING_TABLE_NAME = os.environ['BOOKING_TABLE_NAME']
dynamodb = boto3.resource('dynamodb')
sns = boto3.resource('sns')
topic = sns.Topic(BOOKING_SNS_ARN)
print("DynamoDB table name: " + BOOKING_TABLE_NAME)
print("SNS Topic: " + BOOKING_SNS_ARN)


def randomString(length):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))


# triggered by API Gateway on receiving POST event from web application
def handler(event, context):
    print("From API G/W: " + event)
    body = event['body']
    firstname = body['first_name']
    lastname = body['last_name']
    odfrom = body['from_airport']
    odto = body['to_airport']
    depdate = body['departure_date']
    retdate = body['return_date']
    agegroup = body['age_group']
    bookingclass = body['booking_class']
    bookingid = randomString(8);

    # insert into DynamoDB
    table = dynamodb.Table(BOOKING_TABLE_NAME)
    response = table.put_item(
        Item={
            'bookingid': bookingid,
            'firstname': firstname,
            'lastname': lastname,
            'odfrom': odfrom,
            'odto': odto,
            'depdate': depdate,
            'retdate': retdate,
            'agegroup': agegroup,
            'bookingclass': bookingclass
        }
    )
    print("PutItem succeeded. Response is: " + str(response))

    sns_message = {
        'bookingid': bookingid,
        'odfrom': odfrom,
        'odto': odto,
        'flighttimestamp': depdate
    }
    response = topic.publish(
        Message = json.dumps({'default': json.dumps(sns_message)}),
        MessageStructure = 'json'
    )

    return sns_message
