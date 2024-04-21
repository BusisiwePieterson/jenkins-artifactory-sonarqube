provider "aws" {
  region = "us-east-1"
}

# Create Security group
resource "aws_security_group" "my_sg" {
  name = "lab-sg"
  description = "allow traffic to vpc"
  vpc_id = aws_vpc.vpc.id

  dynamic ingress  {
    iterator = port
    for_each = var.ports
    content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-sg"
  }
}