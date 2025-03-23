Smallcase DevOps Assignment

This repository showcases a fully automated infrastructure deployment using Terraform, AWS, and Docker, as part of the Smallcase DevOps assignment.

Project Structure

 1. main.tf: Terraform code to provision EC2 with KMSencrypted EBS and user data
 2. ec2userdata.sh: Bootstraps EC2 with Docker and runs a Flask API container
 3. variables.tf: Input variables for region and config

 Features

  EC2 instance with public IP
  KMSencrypted EBS volume
  Dynamic Amazon Linux 2 AMI (regionagnostic)
  Flask API container exposed on port 8081
  Random word served on /api/v1


 * Test the App

Once deployed, open in browser:

http://<EC2_PUBLIC_IP>:8081/api/v1


Example response:
json
{"word": "smallcase"}

 How to Deploy

1. terraform init  --Initializes Terraform and downloads required providers.

2. terraform plan   --Terraform will list all the services without making changes.

3. terraform apply -auto-approve  --Creates or updates infrastructure without asking for confirmation.

Security

private PEM file are generated via Terraform (but excluded from repo)

Mallikarjun.M
Senior DevOps Engineer
GitHub: mndevopsgit


