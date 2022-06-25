# 2 - Querying metadata of ec2 instance and returning it as JSON

The primary cloud services of Azure, Google Cloud and Amazon Web Services(AWS) provide internal metadata API's to computer instances within their infrastructure

The requirement for this challenge was to query the metadata service of AWS and format the data output as JSON

I opted to write my solution in C# as it is my strongest language by far so made the most sense to me

The provided source code builds to an executable binary file that can be compiled for either windows or linux based systems, once this exe is obtained it can be copied to an AWS EC2 instance and executed to return the full available metadata object for the instance you executed it on