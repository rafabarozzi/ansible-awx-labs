# Provisioning EC2 Instance and Install Uyuni

## Prerequisites

- Terraform *https://www.terraform.io/downloads.html*
- AWS CLI *https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html*
- AWS EC2 Keypair *https://docs.aws.amazon.com/servicecatalog/latest/adminguide/getstarted-keypair.html*
- Zone in Route53

## Resources created

- 1 EC2 Instance (openSuse Leap 15.5) t2.xlarge with Public IP
- 2 Security Groups (SSH and Web)
- 1 EBS volume of 250 GB for Uyuni use

## How to Use

1. Clone the repository: Clone this repository to your local machine using the following command:

```
git clone https://github.com/rafabarozzi/terraform-on-aws.git
```

2. Navigate to correct folder

```
cd 03-ec2-uyuni-opensuse-basic/terraform-manifest
```

3. Copy your Key pair to Folder *private-key*

4. Edit the Files

```
t2-varibles.tf
Configure your KeyPair

t8-record-route53.tf
Configure your Domain and Subdomain.

config.sh

Line 8 to 13 
Configure your FQDN

Line 59 to 80
Configure your variables

```

5. Initialize Terraform

```
terraform init
```

6. Run code verification

```
terraform plan
```

7. Apply the Terraform configuration

```
terraform apply -auto-approve
```

**Access Uyuni using the DNS.**

*Example: http://uyuni.rbarozzi.com*


8. Destroy the infrastructure

```
terraform destroy -auto-approve
```

**Please be cautious while using the *terraform destroy* command, as it will permanently delete the resources provisioned by Terraform.**


