import boto3
import pandas

# Creating the low level functional client

client = boto3.client('s3',region_name = 'ap-south-1')

# Fetch the list of existing buckets
clientResponse = client.list_buckets()

# Get the S3 object
obj = client.get_object(
    Bucket = 'ruchi0312',
    Key = 'Movies.csv'
)
    
# Read data from the S3 object
data = pandas.read_csv(obj['Body'])

region = 'ap-south-1'
instances = ['i-04be3bf040b503db7']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    if (data.iloc[0,1] == 'on'):
        ec2.start_instances(InstanceIds=instances)
        print('Started(ON) Instance: ' + str(instances))
    elif (data.iloc[0,1] == 'off'):
        ec2.stop_instances(InstanceIds=instances)
        print('Stopped Instance: ' + str(instances))