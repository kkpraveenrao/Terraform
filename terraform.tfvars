aws_region = "us-east-1"
EC2_AMI = "ami-0fc8a85749a35ce56"
EC2_type = "t2.medium"
EC2_key = "MYDC"
EC2_SecurityGroupIDs = ["sg-0cc3b6289ec53b1aa"]
EC2_Role = "DomainJoinTestRole"

EC2_tags = {
  "Name" = "AWSTestServer0"
  "Environment" = "Development"
  "Project"     = "Terraform"
  "CreatedBy" = "PraveenRao"
}



