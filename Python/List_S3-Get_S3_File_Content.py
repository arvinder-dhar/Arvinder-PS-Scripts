"""
Description : This Code needs you to interactively enter the creds which is an unsafe way,
To avoid this way use the IAM Role assignment to EC2 and then remove the access key and ID. The code will then run under the EC2's assumed IAM role

Dependencies : Install the boto3 and pandas module(pip install <module-name>) just in case it is not available at below path
c:\users\<user-name>\appdata\local\programs\python\python36-32\lib\site-packages

Note : To check the module directory run this for any module that you know is available
pip show <module-name>
e.g. pip show pandas

"""

import boto3
import pandas

# Creating the low level functional client
client = boto3.client(
    's3',
    aws_access_key_id = '', #enter the access key of the account that has s3:GetObject, s3:ListAllMyBuckets & s3:ListBucket permissions
    aws_secret_access_key = '', #enter the secret key
    region_name = 'ap-south-1'
)

""" 
# Creating the high level object oriented interface
resource = boto3.resource(
    's3',
    aws_access_key_id = '',
    aws_secret_access_key = '',
    region_name = 'ap-south-1'
)
"""

# Fetch the list of existing buckets
clientResponse = client.list_buckets()
    
# Print the bucket names one by one
print('Printing bucket names...')
for bucket in clientResponse['Buckets']:
    print(f'Bucket Name: {bucket["Name"]}')

# Get the S3 object
obj = client.get_object(
    Bucket = 'ruchi0312',
    Key = 'Movies.csv'
)
    
# Read data from the S3 object
data = pandas.read_csv(obj['Body'])
    
# Print the data frame
print('Printing the data frame...')
print(data)