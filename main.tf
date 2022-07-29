
resource "aws_vpc" "Main" {            # Creating VPC here
  cidr_block       = var.main_vpc_cidr # Defining the CIDR block use 10.0.0.0/16 for demo
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "IGW" { # Creating Internet Gateway
  vpc_id = aws_vpc.Main.id              # vpc_id will be generated after we create VPC
}

resource "aws_subnet" "publicsubnet_01" { # Creating Public Subnets
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.public_subnet_01 # CIDR block of public subnets

}
#[for psn in public_subnets : length(public_subnets)]

resource "aws_subnet" "publicsubnet_02" { # Creating Public Subnets
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.public_subnet_02 # CIDR block of public subnets
}
# Creating Private Subnets
resource "aws_subnet" "privatesubnet_01" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.private_subnet_01 # CIDR block of private subnets
}

resource "aws_subnet" "privatesubnet_02" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.private_subnet_02
}

# Creating DB Subnets
resource "aws_subnet" "dbsubnet_01" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.db_subnet_01 # CIDR block of private subnets
}

resource "aws_subnet" "dbsubnet_02" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.db_subnet_02
}

resource "aws_route_table" "PublicRT" { # Creating RT for Public Subnet
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table" "PrivateRT" { # Creating RT for Private Subnet
  vpc_id = aws_vpc.Main.id
}

resource "aws_route_table_association" "PublicRTassociation_01" {
  subnet_id      = aws_subnet.publicsubnet_01.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_route_table_association" "PublicRTassociation_02" {
  subnet_id      = aws_subnet.publicsubnet_02.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_route_table_association" "PrivateRTassociation_01" {
  subnet_id      = aws_subnet.privatesubnet_01.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route_table_association" "PrivateRTassociation_02" {
  subnet_id      = aws_subnet.privatesubnet_02.id
  route_table_id = aws_route_table.PrivateRT.id
}


resource "aws_route_table_association" "DBRTassociation_01" {
  subnet_id      = aws_subnet.privatesubnet_01.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route_table_association" "DBRTassociation_02" {
  subnet_id      = aws_subnet.privatesubnet_02.id
  route_table_id = aws_route_table.PrivateRT.id
}


# resource "aws_instance" "basion_host" {
#   ami           = "ami-09dd2e08d601bff67"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "Basion Hosted"
#   }


# resource "aws_instance" "basion_host" {
#   ami           = "ami-09dd2e08d601bff67"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "Basion Hosted"
#   }


resource "aws_security_group" "allow_all" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "allow_local" {
  name        = "allow_local"
  description = "Allow local inbound traffic"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.Main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow inbound trafficto db"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description = "db traffic"
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}


resource "aws_instance" "basion_host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.publicsubnet_01.id
  associate_public_ip_address = true
  key_name                    = "test-huybt"
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
}


resource "aws_instance" "web_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.privatesubnet_01.id
  associate_public_ip_address = false
  key_name                    = "test-huybt"
  vpc_security_group_ids      = [aws_security_group.allow_local.id]

}
