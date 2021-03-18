# Working Code below here
import boto3
import json
from tika import parser

s3 = boto3.resource('s3')

bucket = s3.Bucket('some-s3-bucket-after-event')

#List all files in S3

def lambda_handler(event, context):

  for obj in bucket.objects.all():
    key = obj.key
# Testing only with print
    print(key)
    body = obj.get()['Body'].read()
# Testing only with print
    print(body)

    #Execute Tika Perser on text in memory
    content = parser.from_buffer(body)
# More testing with print
    print(content)
    print(type(content))



