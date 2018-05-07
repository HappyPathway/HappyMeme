# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
provider "aws" {
  region = "us-east-1"
}

# Configure the Consul provider
provider "consul" {
  address    = "consul.ops.happypathway.com:8500"
  datacenter = "dc1"
}

variable "service_name" {
  default = "consul_cluster"
}

# Access a key in Consul
data "consul_keys" "aws_infra" {
  
  key {
    name    = "subnet_id"
    path    = "services/${var.service_name}/subnet_id"
    default = ""
  }
  
  key {
    name    = "security_group"
    path    = "services/${var.service_name}/security_group"
    default = ""
  }
  
  key {
    name    = "ami"
    path    = "services/${var.service_name}/ami"
    default = ""
  }

  key {
    name    = "instance_type"
    path    = "services/${var.service_name}/instance_type"
    default = ""
  }

  key {
    name    = "key_pair"
    path    = "services/${var.service_name}/key_pair"
    default = ""
  }

  key {
    name    = "instance_user"
    path    = "services/${var.service_name}/instance_user"
    default = ""
  }
}

resource "aws_instance" "web" {
  ami           = "${data.consul_keys.aws_infra.var.ami}"
  instance_type = "${data.consul_keys.aws_infra.var.instance_type}"
  subnet_id = "${data.consul_keys.aws_infra.var.subnet_id}"
  vpc_security_group_ids = ["${data.consul_keys.aws_infra.var.security_group}"]
  key_name = "${data.consul_keys.aws_infra.var.key_pair}"
  tags {
    Name = "proxy"
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "${data.consul_keys.aws_infra.var.instance_user}"
    }
    source      = "../dev/images"
    destination = "/tmp/images"
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "${data.consul_keys.aws_infra.var.instance_user}"
    }
    source      = "../build/playbooks"
    destination = "/tmp/playbooks"
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "${data.consul_keys.aws_infra.var.instance_user}"
    }
    source      = "proxy_bootstrap.sh"
    destination = "/tmp/proxy_bootstrap.sh"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "${data.consul_keys.aws_infra.var.instance_user}"
    }
    inline = [
      "bash /tmp/proxy_bootstrap.sh"
    ]
  }
  
}


output "ip_address" {
  value = "${aws_instance.web.public_ip}"
}