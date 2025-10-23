resource "aws_msk_configuration" "default" {
  name              = "${var.name_prefix}-config"
  kafka_versions    = [var.kafka_version]
  server_properties = <<EOF
auto.create.topics.enable=false
default.replication.factor=3
min.insync.replicas=2
num.partitions=6
log.retention.hours=168
EOF
}

resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.name_prefix}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.num_broker_nodes
  configuration_info {
    arn      = aws_msk_configuration.default.arn
    revision = aws_msk_configuration.default.latest_revision
  }

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [var.security_group_id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = null
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  monitoring {
    enhanced_monitoring = "PER_TOPIC_PER_PARTITION"
  }

  tags = {
    Name = "${var.name_prefix}-msk"
  }
}
