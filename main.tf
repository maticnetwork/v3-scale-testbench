locals {
  name = "test"
}

# Upload account data to s3
resource "aws_s3_bucket" "state_bucket" {
  bucket = "polygontech-v3-cloud-framework-${local.name}"

  tags = {
    Deployment = local.name
  }
}

resource "aws_s3_object" "account_data" {
  for_each = fileset("./account-data", "**")

  bucket = "${aws_s3_bucket.state_bucket.bucket}"
  key    = each.value
  source = "./account-data/${each.value}"
}

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

resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdATyDZN1ZvHGoIZCjO4IOc8O+IkTvD/vAtG92MZ93y admin-v3-dev"
}

# Deploy bootnode
resource "aws_instance" "bootnode" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web-sg.id]

  key_name   = "admin"

  associate_public_ip_address = true

  user_data = "${templatefile("${path.module}/userdata/bootnode.tpl", {
    docker = "ferranbt/example-v3:latest",
    priv = file("${path.module}/bootnode/priv.key")
  })}"

  tags = {
    Name = "bootnode1"
  }
}

# Create the virtual machines
resource "aws_instance" "app_server" {
  count = "5"

  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web-sg.id]

  key_name   = "admin"

  associate_public_ip_address = true
  iam_instance_profile = "v3-node-role"

  user_data = "${templatefile("${path.module}/userdata/node.tpl", {
    index = count.index
    docker = "ferranbt/example-v3:latest",
    bootnode = "enode://${file("${path.module}/bootnode/pub.key")}@${aws_instance.bootnode.public_ip}:30303"
    bucket = aws_s3_bucket.state_bucket.bucket
    dd_api_key = data.aws_ssm_parameter.dd_api_key.value
  })}"

  tags = {
    Name = "machine-${count.index}"
  }
}

output "bootnode" {
  value = "${aws_instance.bootnode.public_ip}"
}
