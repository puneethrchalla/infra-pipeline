resource "aws_placement_group" "static_cluster_placement_gp" {
  name     = "${var.placement_gp_name}"
  strategy = "spread"
}

data "template_file" "user_data" {
  count    = "${var.static_instance_count}"
  template = "${file("user_data.sh")}"

  vars {
    env   = "${var.environment}"
    vault_ip   = "${var.vault_ip}"
    vault_port = "${var.vault_port}"
    count = "${count.index}"
  }
}

resource "aws_instance" "instance" {
  count                                = "${var.static_instance_count}"
  key_name                             = "${var.key_name}"
  associate_public_ip_address          = false
  vpc_security_group_ids               = ["${aws_security_group.static_cluster_sg.id}","${data.terraform_remote_state.layer_network.mgmt_trusted_sg}"]
  subnet_id                            = "${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), count.index % data.terraform_remote_state.layer_network.az_count)}"
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = "${var.ec2_instance_profile}"
  source_dest_check                    = true
  ami                                  = "${var.cluster_ami_id}"
  instance_type                        = "${var.static_instance_type}"
  placement_group                      = "${aws_placement_group.static_cluster_placement_gp.id}"
  user_data                            = "${element(data.template_file.user_data.*.rendered, count.index + 1)}"

  ebs_block_device {
    volume_size           = "${var.volume_size}"
    delete_on_termination = true
    device_name           = "/dev/xvdb"
    encrypted             = true
  }

  tags = {
    Name                = "${var.project}-${var.environment}-CLUSTER-0${count.index + 1}"
    Environment         = "${var.environment}"
    Service             = "Static Cluster"
    Role                = "${var.role}"
    CreatedBy           = "${var.user-email}"
    Resource            = "EC2"
    Tier                = "${var.tier}"
    Monitoring          = "On"
    iSCSI-Mount         = "No"
    AMI_Backup_Policy   = "N/A"
    Owner               = "${var.owner}"
    SecurityAgentStatus = "False"
    gig-backup          = "3d2w1m"
  }
}

resource "aws_elb_attachment" "cluster_elb_attachment" {
  count    = "${var.static_instance_count}"
  elb      = "${data.terraform_remote_state.layer_elb.static_cluster_elb_id}"
  instance = "${element(aws_instance.instance.*.id, count.index)}"
}
