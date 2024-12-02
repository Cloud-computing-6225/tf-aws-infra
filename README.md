# Infrastructure Setup using Terraform

This project automates the creation of AWS infrastructure using Terraform. It sets up a Virtual Private Cloud (VPC), public and private subnets, and associates them with route tables. The subnets are dynamically distributed across the available AWS availability zones.

## Prerequisites

Before you can begin, ensure that you have the following prerequisites installed and configured:

- [Terraform](https://www.terraform.io/downloads.html) (v0.12+)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- AWS credentials properly set up (either through `aws configure` or environment variables)

### AWS Permissions

Ensure the user running Terraform has the necessary permissions to create VPCs, subnets, route tables, and related resources.

## Steps to Set Up the Infrastructure

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone <your-repo-url>
cd <your-repo-directory>
2. Configure Variables
You need to provide values for the variables used in the Terraform configuration. Update the terraform.tfvars file with your specific configurations.

Here’s an example of what your terraform.tfvars might look like:

hcl
Copy code
vpc_name               = "VPC Name"
public_subnet_cidrs    = ["3 public CIDRs"]
private_subnet_cidrs   = ["3 private CIDRs"]
region                 = "region of choice"
3. Initialize Terraform
Before deploying the infrastructure, you need to initialize Terraform. This step downloads the necessary provider plugins and sets up the backend:


terraform init

4. Validate the Configuration
To ensure that your configuration files are correct, run the following command:


terraform validate
This will check your Terraform code for syntax issues.

5. Plan the Infrastructure
Run terraform plan to see what Terraform will create. This is a dry run that shows you the resources it will create without actually deploying them:


terraform plan
Review the output to ensure it aligns with your expectations.

6. Deploy the Infrastructure
Once you're satisfied with the plan, apply the changes to deploy the infrastructure:


terraform apply
Terraform will display the resources it intends to create and prompt you for confirmation. Type yes to proceed.

7. Destroy the Infrastructure (Optional)
If you need to tear down the infrastructure at any point, you can run the following command:


terraform destroy
This will remove all resources that were created by Terraform.

Dynamic Availability Zones
The subnets are distributed dynamically across the available availability zones in the region. If the region has fewer than 3 zones, Terraform will automatically adjust and create subnets in the available zones.

This is achieved by using the following Terraform data source:


data "aws_availability_zones" "available" {
  state = "available"
}
The number of subnets created is dynamically adjusted based on the number of availability zones:


count = min(3, length(data.aws_availability_zones.available.names))
Importing SSL Certificate
If you are using a third-party SSL certificate provider like Namecheap, you can import the SSL certificate into AWS Certificate Manager (ACM) using the following AWS CLI command:


aws acm import-certificate \
    --certificate fileb:///Users/ashwinnair/Documents/demo_ashwinnair.me/demo_ashwinnair_me.crt \
    --certificate-chain fileb:///Users/ashwinnair/Documents/demo_ashwinnair.me/demo_ashwinnair_me.ca-bundle \
    --private-key fileb:///Users/ashwinnair/demo.ashwinnair.me.key \
    --region us-east-1
Ensure that the file paths match the location of your certificate, certificate chain, and private key files. Replace us-east-1 with your desired AWS region if necessary.