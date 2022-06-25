# KPMG DevOps Technical Assessment

The contents of this repository set out to satisfy the requirements of the below challenges

A more specific write-up of each of my challenges solutions can be found in the readme of the respective folders

## Challenge 1

A 3 tier environment is a common setup. Use a tool of your choosing/familiarity create these resources. Please remember we will not be judged on the outcome but more focusing on the approach, style and reproducibility.

## Challenge 2

### Summary

We need to write code that will query the meta data of an instance within aws and provide a json formatted output. The choice of language and implementation is up to you.

### Bonus Points

The code allows for a particular data key to be retrieved individually

### Hints

* [Aws Documentation](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
* [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service)
* [Google Documentation](https://cloud.google.com/compute/docs/storing-retrieving-metadata)

## Challenge 3

We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.

### Example Inputs

```text
object = {“a”:{“b”:{“c”:”d”}}}

key = a/b/c

value = d
```

```text
object = {“x”:{“y”:{“z”:”a”}}}

key = x/y/z

value = a
```

### Hints

We would like to see some tests. A quick read to help you along the way
