locals {
  prefix = "${var.project}-${var.environment}"
  public = {
    for index, az in var.availability_zones : az => {
      az   = az
      cidr = cidrsubnet(var.vpc_cidr, 8, index)
    }
  }
  isolated = {
    for index, az in var.availability_zones : az => {
      az   = az
      cidr = cidrsubnet(var.vpc_cidr, 8, index + 10)
    }
  }
}

resource "aws_vpc" "platform" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${local.prefix}-vpc" }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.platform.id
  tags   = { Name = "${local.prefix}-igw" }
}

resource "aws_subnet" "public" {
  for_each                = local.public
  vpc_id                  = aws_vpc.platform.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.prefix}-public-${each.key}", Tier = "public" }
}

resource "aws_subnet" "isolated" {
  for_each                = local.isolated
  vpc_id                  = aws_vpc.platform.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false
  tags                    = { Name = "${local.prefix}-isolated-${each.key}", Tier = "isolated" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.platform.id
  tags   = { Name = "${local.prefix}-public-rt" }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.platform.id
  tags   = { Name = "${local.prefix}-isolated-rt" }
  # No default route: workloads here cannot reach the public internet.
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "isolated" {
  for_each       = aws_subnet.isolated
  subnet_id      = each.value.id
  route_table_id = aws_route_table.isolated.id
}
