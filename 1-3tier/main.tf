terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.19.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

variable "db_name" {
  type    = string
  default = "db1"
}

variable "db_user" {
  type    = string
  default = "admin"
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "db_password" {
  type = string
}

variable "app_port" {
  type    = number
  default = 80
}

resource "aws_key_pair" "key_pair" {
  key_name   = "alex_siada_io"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDObiVBmjyjcXzb+OWdBhTID2FchoDRvtLqF9+JHx8lhM1pep83cfuQ9LgDPYHDWWJYdMgBZ1X8ruUlXO6Zpy4W6sDWY8gpo0/bVioJqELjsmZ3EkuVUevFh6LT4mRqjNHm7YVQcI91LMdPH11ybxf36vwqLdUkoVyVhlko+B+DSJzeIExa2ja4aUMskgLMlcRmQxmcBt9hPRINwKk8Tm6oHUcRuUXU93HiUvpM5xiSuVLK8bNhoTucBPBB1BRk/0/tV85YB9XwYOT+p/WAqe8LMBfxTtY/oKRBU83CQ/8QmrxiX+Rm19g1N3QDyoM2RpSfE7rGag8FlCQv3690TaPRvVdfCmSMFv/k1GphbcV1rV+hzAegrh5NRYAM+bV6bnpQFASJUxfw2fvf60+HawYy68xzVCHz5FQT3JPaPKde28uZxELRdliHLm2CJzfJKAUzJhf/T7iOJ4DF+/zCrIWcNqtIwxFBRPBAul3X2QtXn9NT0cX4HO8x4fZGnXa1sEzVJfI0mvi4sSWH4cQUkKCyV+spmOe/TOdbJrqcc6qx8rfNEnrjKoUbjS7y1I7zhpAlur51bo7GWrUB4obncE5/Q0VP6zyBlSVPU5DX6sqaJ6t7ahhHGqAlydo+hvnbofQzTgbWDtA3WyprhqUkejEMskrP75eVhnxVMY50CcvqPQ=="
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "kpmg-tech-vpc" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "webtier-igw" {
  vpc_id = aws_vpc.kpmg-tech-vpc.id
}

resource "aws_route_table" "webtier-rt" {
  vpc_id = aws_vpc.kpmg-tech-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webtier-igw.id
  }
}

resource "aws_route_table_association" "webtier_assoc" {
  subnet_id      = aws_subnet.kpmg-tech-subnet.id
  route_table_id = aws_route_table.webtier-rt.id
}

resource "aws_subnet" "kpmg-tech-subnet" {
  vpc_id                  = aws_vpc.kpmg-tech-vpc.id
  cidr_block              = "172.31.32.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "kpmg-tech-db1-subnet" {
  vpc_id            = aws_vpc.kpmg-tech-vpc.id
  cidr_block        = "172.31.33.0/24"
  availability_zone = "eu-west-2a"
}

resource "aws_subnet" "kpmg-tech-db2-subnet" {
  vpc_id            = aws_vpc.kpmg-tech-vpc.id
  cidr_block        = "172.31.34.0/24"
  availability_zone = "eu-west-2b"
}

resource "aws_security_group" "frontend-tier-sec" {
  name   = "frontend-tier-sec"
  vpc_id = aws_vpc.kpmg-tech-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend-tier-sec" {
  name   = "backend-tier_sec"
  vpc_id = aws_vpc.kpmg-tech-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dbtier-sec" {
  name   = "dbtier_sec"
  vpc_id = aws_vpc.kpmg-tech-vpc.id
  ingress {
    security_groups = [aws_security_group.frontend-tier-sec.id, aws_security_group.backend-tier-sec.id]
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
  }

}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.kpmg-tech-db1-subnet.id, aws_subnet.kpmg-tech-db2-subnet.id]
}

data "template_file" "frontend-init" {
  template = file("configure_frontendtier.sh")

  vars = {
    backend_dns = aws_instance.backend-tier.public_dns
    app_port    = var.app_port
  }
  depends_on = [
    aws_instance.backend-tier
  ]
}
resource "aws_instance" "frontend-tier" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "alex_siada_io"
  vpc_security_group_ids = [aws_security_group.frontend-tier-sec.id]
  subnet_id              = aws_subnet.kpmg-tech-subnet.id
  user_data              = data.template_file.frontend-init.rendered
  tags = {
    Name = "frontend"
  }
}

data "template_file" "backend-init" {
  template = file("configure_backendtier.sh")

  vars = {
    db_ip       = aws_db_instance.db-tier.address
    db_user     = aws_db_instance.db-tier.username
    db_password = var.db_password
    db_name     = var.db_name
    db_port     = var.db_port
    app_port    = var.app_port
  }
  depends_on = [
    aws_db_instance.db-tier
  ]
}

resource "aws_instance" "backend-tier" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "alex_siada_io"
  vpc_security_group_ids = [aws_security_group.backend-tier-sec.id]
  subnet_id              = aws_subnet.kpmg-tech-subnet.id
  user_data              = data.template_file.backend-init.rendered
  tags = {
    Name = "backend"
  }
}

resource "aws_db_instance" "db-tier" {
  instance_class         = "db.t3.micro"
  engine                 = "mysql"
  engine_version         = "8.0.28"
  username               = var.db_user
  password               = var.db_password
  allocated_storage      = 20
  vpc_security_group_ids = [aws_security_group.dbtier-sec.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.id
  port                   = var.db_port
  db_name                = var.db_name
}

output "backend_hostname" {
  value = aws_instance.backend-tier.public_dns
}

output "frontend_hostname" {
  value = aws_instance.frontend-tier.public_dns
}

output "dbtier_hostname" {
  value = aws_db_instance.db-tier.address
}
