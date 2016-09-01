This project is meant to be used with the express purpose of standing up 
an RDS cluster, running Aurora, in AWS for benchmarking.


This project requires using S3 as the remote storage backend.


```bash
terraform remote config \
    -backend=s3 \
    -backend-config="bucket=terraform-state-here" \
    -backend-config="key=project/terraform.tfstate" \
    -backend-config="region=your-region"
```

The project will provide:
- VPC w/ 4 Subnets (2 public, 2 private)
- Managed Nat Gateway(s)
- Bastion box (jumpbox)
- 2 Client instances to initiate the test
- Security Groups (these are wide open, take caution)
- Basic IAM roles&profiles
- A Multi-zone RDS Aurora cluster w/ 2 instances @ r3.4xlarge
- A Multi-zone RDS Aurora cluster w/ 2 instances @ r3.8xlarge


Intially stand up the 4x environment first, run the gendata.sh script to populate the database.
This script will add 100 tables with 20m rows each. 

Prior to running the tests you must make a small change to the userlimits for your environment.

```bash
$ ulimit -n 4086
```
This will change the max open files to 4086 files as opposed to the initial setting of 1024, allowing 
us to run more than 1000 threads. The original test data only went up to 512, but we wanted to go further 
Aurora for our own curiousity.

After that is set you are almost ready to run the test.


I recommend firing off a snapshot now, so you can then spin-up the 8x environment from snapshot and avoid loading 
the data twice.

When connecting to RDS via the client instance, your endpoint may not be the writer. If 
this is the case, just initiate a failover in RDS for Aurora and you can begin testing 
in that AZ, or alternatively modify the "runtest.sh" file in the client instance with the 
appropriate hostname for the RDS instance you wish to connect to.



Work in progress, illustrating some new ideas in Terraform
