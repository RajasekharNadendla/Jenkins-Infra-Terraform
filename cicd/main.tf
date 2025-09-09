module "jenkins"{
    source  = "terraform-aws-modules/ec2-instance/aws"
    name = "jenkins-tf"
    instance_type = "t3.small"
    vpc_security_group_ids = ["sg-033297d264125ae07"]
    subnet_id = "subnet-0a416220bce54db2e"
    ami = data.aws_ami.ami_info.id
    user_data=file("jenkins.sh")
    tags = {
        Name = "jenkins-tf"
    }
  
}



module "jenkins_agent" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    name = "jenkins-agent"
    instance_type = "t3.small"
    vpc_security_group_ids = ["sg-033297d264125ae07"]
    subnet_id = "subnet-0a416220bce54db2e"
    ami = data.aws_ami.ami_info.id
    user_data = file("jenkins-agent.sh")
    tags = {
        Name = "jenkins-agent"
      }
}

resource "aws_key_pair" "tools" {
 key_name   = "tools"
  # you can paste the public key directly like this
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKXBWAXA04P0Jq4/pWZXqJHSNQTCBaLS4m4N8U6NVmlLs1ZJRmGvCyqpUcUQGrX52G7YmnPXf5kugUzeibwsrEAElzHoYpqr2faKKhZqulvBgLt6LtltbYgFBaFQhJ5Yjmb6plS108NkgBZgrrrEE7/kcUFhIm5QryzaxhNgTqsVFxJW4POaDz8bDIkymNkhed8GmZ0dvT1OJAOembjyajKP5PjY6mnX22BN5I3My+idhM52JOyUOO9fPOBbomjgrVPCBRf7ZTvj8ZLQFxdH+G5Bu7y9y4mzVgTGKt65ox/Ctq6YNotWoS4cQ/mP41BsOzwbD3PbpmkfWd5bjjif/6HKF3wt4FOTPqpbCFDADNhh5EvjZ4eJdHb1A6rYeZxbF02VKulDSNoROAZUw+4m6Pr2j6ef4n+tNPLsCrD0kkQowY+ZFU/RTM5gJbGvbw9WJPV4Jbg4BNnV0xJLyv4yg0OCHQL3et/Dy/I2fZgssLNe6fnNwBsyOq0YM4qH45AdMHJ6+1+b5+lC3jcUmYuxFzNANi0r957viSksSVD3i04xbbDfh2Z+0Gqe2wUT1lpUe7WWmP6a+ZuS/oEj1m0rG3zWOaVWeK3YAqFHdz/9hN6BLd81/V+hSPBXBENZKhFtH3ZhL4oXM4ZNWQVXDOk1Z9YS6/LzOF8knJN3D3vKaIbQ== Nadendla.Rajasekhar@Rajasekhar15-laptop"
# public_key = file("~/.ssh/tools.pub")
  # ~ means windows home directory
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-033297d264125ae07"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0a416220bce54db2e"
  ami = "ami-00ca32bbc84273381"
  key_name = aws_key_pair.tools.key_name
  user_data = file("nexus.sh")
  tags = {
    Name = "nexus"
  }
}

module "SonarQube" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "SonarQube"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-033297d264125ae07"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0a416220bce54db2e"
  ami = "ami-00ca32bbc84273381"
  key_name = aws_key_pair.tools.key_name
  user_data = file("SonarQube.sh")
  tags = {
    Name = "nexus"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    
    },
    {
      name    = "nexus"
     type    = "A"
     ttl     = 1
     allow_overwrite = true
     records = [
       module.nexus.private_ip
     ]
     allow_overwrite = true
    }
  ]

}