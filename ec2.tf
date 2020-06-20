#provider block

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

    

#Create EC2 instance
resource "aws_instance" "TestInstance1" {
  ami             = "ami-09d95fab7fff3776c"
  instance_type   = "${var.instance_type}"
  count = 1
  key_name = "awskey1"
  vpc_security_group_ids = [
      "${aws_security_group.webSG.id}",
  ]
  tags = {
    Name = "Test"
  }

   connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file("awskey1.pem")}"
  }

  provisioner "file" {
  source      = "httpd.sh"
  destination = "/tmp/httpd.sh"
  }

  #provisioners - remote-exec 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/httpd.sh",
      "sudo /tmp/httpd.sh"
    ]
    } 
  }

#resources

#Create Security Group  
resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"
  vpc_id      = "vpc-f0525289"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}



#outputs

output "TestInstance1_pub_ip" {
    value = "${aws_instance.TestInstance1.0.public_ip}"
}

output "TestInstance1_id" {
    value = "${aws_instance.TestInstance1.0.id}"
}
