resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block

  tags = merge({
    Name = var.vpc_config.name
  }, var.custom_tags)
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id

  for_each = var.subnet_config
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.assign_public_ip

  tags = merge({
    Name = each.key
  }, var.custom_tags)
}

#Internet Gateway if atleast one public subnet
locals {
  public_subnet_config = {
    #key = {} if public is true in subnet_config
    for key, config in var.subnet_config: key => config if config.public
  }
}

resource "aws_internet_gateway" "main" {
  count = length(local.public_subnet_config) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${aws_vpc.main.tags.Name}-IG"
  }, var.custom_tags)
}

#Creating route table if public subnet exists

resource "aws_route_table" "main" {
  count = length(local.public_subnet_config) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[count.index].id
  }

  tags = merge({
    Name = "${aws_vpc.main.tags.Name}-PublicRT"
  }, var.custom_tags)
}

#associating public subnets with route tables
#finding subnet id from aws_subnet for each paired config of public subnet
#that were stored for all subnets were publis was true
resource "aws_route_table_association" "main" {
  for_each = local.public_subnet_config

  subnet_id = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[0].id
}

#Nat Gateway for private subnet
#key-pair config for all private subnets with allow_nat configuration
locals {
  private_nat_config = {
    for key, config in var.subnet_config: key => config if config.allow_nat
  }
}
locals {
  private_subnets_config = {
    for key, config in var.subnet_config : key => config if !(config.public)
  }
}

#eip for public nat gateway
# Create an Elastic IP for NAT Gateway

resource "aws_eip" "main" {
  count = length(local.private_nat_config) > 0 ? 1 : 0

  domain = "vpc"

  tags = merge({
    Name = "${aws_vpc.main.tags.Name}-EIP"
  }, var.custom_tags)
}

resource "aws_nat_gateway" "main" {
  count = length(local.private_nat_config) > 0 ? 1 : 0

  allocation_id = aws_eip.main[0].id
  #first public subnet of the public subnet config
  subnet_id = aws_subnet.main[keys(local.public_subnet_config)[0]].id

  connectivity_type = "public"

  tags = merge({
    Name = "${aws_vpc.main.tags.Name}-nat"
  }, var.custom_tags)
}


#Private Route Table
resource "aws_route_table" "private-rt" {
  count = length(local.private_nat_config) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge({
    Name = "${aws_vpc.main.tags.Name}-PrivateRT"
  }, var.custom_tags)
}

#private subnet - private route table Association
resource "aws_route_table_association" "private-association" {
  for_each = local.private_nat_config

  subnet_id = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private-rt[0].id
}