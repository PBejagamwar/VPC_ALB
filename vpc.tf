resource "aws_vpc" "us_vpc" {

    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      name = "sun-vpc"
    }

}

variable "vpc_availability_zones" {

    type = list(string)
    description = "Availability Zone"
    default = [ "us-east-1a", "us-east-1b" ]

}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.us_vpc.id
    count = length(var.vpc_availability_zones)
    cidr_block = cidrsubnet(aws_vpc.us_vpc.cidr_block, 8, count.index + 1 )
    availability_zone = element(var.vpc_availability_zones, count.index)
    tags = {
      name = "Sun Public Subnet ${count.index + 1 }"
    }

}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.us_vpc.id
    count = length(var.vpc_availability_zones)
    cidr_block = cidrsubnet(aws_vpc.us_vpc.cidr_block, 8, count.index + 3)
    availability_zone = element(var.vpc_availability_zones, count.index)
    tags = {
      name = "Sun Private Subnet ${count.index + 1}"
    }
  
}

resource "aws_internet_gateway" "igw_vpc" {
    vpc_id = aws_vpc.us_vpc.id
    tags = {
      name = "Sun Internet Gateway"
    }
  
}

resource "aws_route_table" "route_table_public_subnet" {
    vpc_id = aws_vpc.us_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc.id
    }
    tags = {
        name = "Public Subnet Route Table"
    }

}

# Route table association with public subnet 
resource "aws_route_table_association" "public_subnet_association" {
    route_table_id = aws_route_table.route_table_public_subnet.id
    count = length(var.vpc_availability_zones)
    subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
  
}

# Elastic IP
resource "aws_eip" "eip" {
    domain = "vpc"
    depends_on = [ aws_internet_gateway.igw_vpc ]

}


