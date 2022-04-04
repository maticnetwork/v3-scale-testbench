
variable "name" {
    type = string
}

variable "num" {
    type = number
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

/*
# Upload account data to s3
resource "aws_s3_bucket" "state_bucket" {
  bucket = "polygontech-cloud-framework-${var.name}"

  tags = {
    Deployment = "${var.name}"
  }
}

resource "aws_s3_bucket_object" "account_data" {
  for_each = fileset("./account-data", "**")

  bucket = "${aws_s3_bucket.state_bucket.bucket}"
  key    = each.value
  source = "./account-data/${each.value}"
}
*/

resource "aws_security_group" "web-sg" {
  name = "ethnode-sg-1"

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = "xxs"
  }
}

/*
# Deploy bootnode
resource "aws_instance" "bootnode" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  user_data = "${templatefile("${path.module}/userdata/bootnode.tpl", {
    docker = "ferranbt/example:latest",
    name = "${var.name}",
    priv = file("${path.module}/bootnode/priv.key")
  })}"

  associate_public_ip_address = true

  key_name = "simple"

  subnet_id = aws_subnet.my_subnet.id

  tags = {
    Deployment = "${var.name}"
  }
}
*/

/*
# Create the virtual machines that connect to bootnode
resource "aws_instance" "app_server" {
  count = "${input.num}"

  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  user_data = "${templatefile("${path.module}/userdata/node.tpl", {
    name = "${input.name}"
  })}"

  tags = {
    Deployment = "${input.name}"
  }
}
*/

/*
output "bootnode" {
  value = "${aws_instance.bootnode.public_ip}"
}
*/
