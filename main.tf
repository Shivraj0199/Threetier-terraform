terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      version = "~>3.1"
    }
  }
}
provider "aws" {
  region = var.region_name
}

//VPC RESOURCE BLOCK
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-custom-vpc"
  }
}

// here internet gatway block
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

//here Subnet Block
    //this is web-tier subnet
resource "aws_subnet" "websubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "websubnet"
  }
}
    // this is app-tier subnet
 resource "aws_subnet" "appsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "appsubnet"
  }
}
    // this is db-tier subnet
resource "aws_subnet" "dbsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.32.0/20"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "dbsubnet"
  }
}

// Routh Tables Block
   // This Is public Routh Table Block

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

   // this is private rout table block
resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "pvt-rt"
  }
}

// Routh Association Block
  // This Association For Web-tier
resource "aws_route_table_association" "web_assoc" {
  subnet_id      = aws_subnet.websubnet.id
  route_table_id = aws_route_table.public-rt.id
}

  // This association For App-tier
resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.appsubnet.id
  route_table_id = aws_route_table.pvt_rt.id
}

  // This association For DB_Tier
resource "aws_route_table_association" "db_assoc" {
  subnet_id      = aws_subnet.dbsubnet.id
  route_table_id = aws_route_table.pvt_rt.id
}


//Security Group Block
  // This Security Group For Web-tier
resource "aws_security_group" "websg" {
  name   = "webmy-sg"
  vpc_id = aws_vpc.myvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
     cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
   ingress {
     cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}

 // This Security Group For App-tier
resource "aws_security_group" "appsg" {
  name   = "app-sg"
  vpc_id = aws_vpc.myvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
   ingress {
     cidr_blocks = ["10.0.0.0/20"]
    from_port   = 9000
    protocol    = "tcp"
    to_port     = 9000
  }
} 

  // This Is Security Group For DB-Tier
  resource "aws_security_group" "dbsg" {
  name   = "db-sg"
  vpc_id = aws_vpc.myvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
   ingress {
     cidr_blocks = ["10.0.16.0/20"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
}

## Here Instance Block..!!
  //This Is App Instance..!
resource "aws_instance" "webec2" {
  subnet_id = aws_subnet.websubnet.id
  ami           = var.my_ami
  key_name = "kubernet"
  instance_type = var.inst_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.websg.id]
  tags = {
    Name = "webInstance"
  }
}

  // This Is App Instance..!
resource "aws_instance" "appec2" {
  subnet_id = aws_subnet.appsubnet.id
  ami           = var.my_ami
  instance_type = var.inst_type
  key_name = "kubernet"
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.appsg.id]
  tags = {
    Name = "appinstance"
  }
}  

// This Is DB_tier Using RDS 
 //RDS block
resource "aws_db_instance" "db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "pass12345"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.mysubnetgp.name
}

//DB Subnet Group Block
resource "aws_db_subnet_group" "mysubnetgp" {
  name       = "mysubnetgp"
  subnet_ids = [aws_subnet.appsubnet.id, aws_subnet.dbsubnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}
