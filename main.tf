data "aws_vpc" "main" {
  id = var.vpc_id
 # id = "vpc-e1fd5787"

}


resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.my_ip_with_cidr]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description = "outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIYs7KN2jF9nEKTvWHquoV4qqTgtHfGRomAGhSL1KXYHnPWfAZGk92yqp6yUCYh+kLhVU91EaAmwljSK89MkyRS8djsmSGDXmEaDNOypTUkdpO33rtvzx5Q40M/nfIzCAJA2xJxWk7IFKAGhGc5cUNPI+t5jCsYsdV7pPgVOY5QXGDSraZpTV5r56Pe2lQMBhknZGVw4gCQZhFOHdqzVLGwB4NLno8sfyr5F62F6kg5jTRTWSSIoEywQFD1uBzoBPe58SCZByJIPSFW3kOhNjix/FoeBccPvGYMPeZep89PpwKNUWCGAnXEbYIHcBshg9j4TmtmXjtJnV5bTL3jWoIfvGzn4qxOsLVPBEny88SkHIkN44Q2QoT3sF8TWogoULKS6JoW41dp4nUXYA5nsZinI5pp1e5oaocg8dnl4ewlfeWxw+GK2GX4naWnykmizkiSIhNYS8lFF2iDMRTJ6W/JTOp19ginhYL/7D3sMeDKNIIntt8BVdc4je+jbX37Bs= user@LAPTOP-QCJ1EQDV"
  public_key = var.public_key
}

data "template_file" "user_data" {
 # template = file("./terraform-aws-apache-example/userdata.yaml")
 template = file("${abspath(path.module)}/userdata.yaml")
}

data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "owner-alias"
        values = ["amazon"]
    }

    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
}

resource "aws_instance" "my_server" {
  #ami           = "ami-051317f1184dd6e92"
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data = data.template_file.user_data.rendered

  tags = {
    Name = var.server_name
  }
}

