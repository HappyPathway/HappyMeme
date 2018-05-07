resource "null_resource" "service_config" {
  
  count = "${var.count}"
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", var.triggers)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
      type     = "ssh"
      host     = "${element(var.hosts, count.index)}"
      user     = "${data.consul_keys.aws_infra.var.instance_user}"
  }

  provisioner "file" {
    source      = "../dev/images"
    destination = "/tmp/images"
  }

  provisioner "file" {
    source      = "../build/playbooks"
    destination = "/tmp/playbooks"
  }

  provisioner "file" {
    source      = "proxy_bootstrap.sh"
    destination = "/tmp/proxy_bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/proxy_bootstrap.sh ${var.proxy_name}"
    ]
  }