mock_provider "aws" {}

run "network_layout" {
  command = plan
  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.isolated) == 2
    error_message = "Expected two public and two isolated subnets."
  }
  assert {
    condition     = aws_vpc.platform.enable_dns_hostnames && aws_vpc.platform.enable_dns_support
    error_message = "VPC DNS features must be enabled."
  }
  assert {
    condition     = aws_route.internet.destination_cidr_block == "0.0.0.0/0"
    error_message = "Only the public route table should route through the internet gateway."
  }
  assert {
    condition     = aws_subnet.public["us-east-1a"].cidr_block == "10.42.0.0/24" && aws_subnet.isolated["us-east-1b"].cidr_block == "10.42.11.0/24"
    error_message = "CIDRs must be derived deterministically from the VPC prefix."
  }
  assert {
    condition     = alltrue([for subnet in aws_subnet.public : !subnet.map_public_ip_on_launch])
    error_message = "Public subnets should not assign public IPs by default."
  }
}

run "alternate_environment" {
  command = plan
  variables {
    environment = "staging"
  }
  assert {
    condition     = aws_vpc.platform.tags.Name == "platform-lab-staging-vpc"
    error_message = "Resources must use the selected environment in their names."
  }
}
