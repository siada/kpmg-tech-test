# 1 - Create a 3-tier environment using tools of my choosing

For this challenge the requirement is to create a 3-tier environment (web tier, backend tier, database tier)

I opted to use terraform as it is the IAC tool I am most familiar with

A demo application can be found at the following URL:

[http://ec2-18-130-207-119.eu-west-2.compute.amazonaws.com/](http://ec2-18-130-207-119.eu-west-2.compute.amazonaws.com/)

This should show something like "You are the 301st visitor!", but the number will change each time the page is landed on. The ordinalised number is retrieved from the back end API, which queries the database to get the current value and subsequently increments it

The back end tier will also initialize the database and it's table(s) on first run, to ensure the schema is in place

---

## Usage

To create the 3-tier envionent, using terraform execute the following commands:

```bash
terraform init
```

followed by:

```bash
terraform apply -var="db_password=<enter a secure password>"
```

This will create the following resources:

* SSH Key Pair
* 172.31.0.0/16 VPC block
* Internet gateway
* Route Table
* Route Table Association
* 3 Subnets
  * 172.31.32.0/24 for the front+back end tiers
  * 172.31.33.0/24 as priamry subnet for database tier in az eu-west-2a
  * 172.31.34.0/24 as a backup subnet for database tier in az eu-west-2b
* Security Group for front end
  * ingress 80:80 -> 0.0.0.0/0
  * ingress 22:22 -> 0.0.0.0/0
  * empty egress
* Security Group for back end
  * ingress 80:80 -> 0.0.0.0/0
  * ingress 22:22 -> 0.0.0.0/0
  * empty egress
* Security Group for database
  * ingress (var)db_port for the above 2x web tier security groups
* DB Subnet Group for db1 subnet+db2 subnet
* Template file for front end tier user_data input
  * This is a bash script that installs nginx web server, and overwrites the /var/www/html/index.html file with a simple front-end that makes an HTTP "api call" to the backend tier
* front end tier EC2 instance
  * using the previously defined VPC, subnet and user data, creates the front end EC2 instance
* Template file for back end tier user_data input
  * This is a bash script that installs nodejs, and creates an index.js file that acts as the api, connecting to the database tier to keep track of the data for this application
* Back end tier EC2 instance
  * Using the previously defined VPC, subnet and user data creates the back end EC2 instance
* RDS Database instance
  * Creates a 20GB db.t3.micro MySQL database in RDS

The terraform file has the following input variables:

* db_name (optional): name of the database [default: db1]
* db_user (optional): name of the root user for the instance [default: admin]
* db_port (optional): port number to use for the db instance [default: 3306]
* db_password (REQUIRED): password for the root user of the instance
* app_port (optional): port number that the nodejs back end tier runs on [default: 80]

The terraform file has the following outputs:

* backend_hostname: this is the public FQDN of the back end instance that is passed into the front-end tier to allow it to make api calls to the right location
* frontend_hostname: this is the public FQDN of the front end instance, this is what you can use in your browser to view the application
* dbtier_hostname: this is the internal FQDN of the database instance, doesn't really serve much of a purpose in this case though, however if the database was publically available you could connect to it using this output