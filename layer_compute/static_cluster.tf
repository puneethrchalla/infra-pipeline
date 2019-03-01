resource "aws_instance" "instance" {
  count                                = "${var.instance_count}"
  key_name                             = "${var.key_name}"
  associate_public_ip_address          = false
  vpc_security_group_ids               = ["${aws_security_group.static_cluster_sg.id}","${data.terraform_remote_state.layer_network.mgmt_trusted_sg}"]
  subnet_id                            = "${element(split(",", data.terraform_remote_state.layer_network.App_Subnet_ID), count.index % data.terraform_remote_state.layer_network.az_count)}"
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = "${var.ec2_instance_profile}"
  source_dest_check                    = true
  ami                                  = "${var.ami_id}"
  instance_type                        = "${var.instance_type}"

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
