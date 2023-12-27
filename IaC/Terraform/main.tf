provider "aws" {
    profile = "terraform"
    region = "ap-northeast-1"
}

resource "aws_instance" "hello-world" {
    ami = "ami-0dfa284c9d7b2adad"
    instance_type = "t2.micro"

    tags = {
        Name = "hello-world!"
    }

    user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start nginx
systemctl enable nginx
EOF
}
