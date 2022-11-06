resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "tf101-aurora-subnet-group"
  subnet_ids = [var.db_subnet_id_0, var.db_subnet_id_1]

  tags = merge(var.tags, {
    Name = "tf101-aurora-subnet-group"
  })
}

resource "aws_db_security_group" "aurora_sg_group" {
  name = "tf101-aurora-sg"

  ingress {
    security_group_id = var.app_sg_id
  }
  tags = merge(var.tags, {
    Name = "tf101-aurora-sg"
  })
}

resource "aws_db_parameter_group" "aurora_instance_parameter_group" {
  name   = "aurora-instance-mysql8"
  family = "aurora-mysql8.0"

  description = "DMS Test Parameter Group"

  dynamic "parameter" {
    for_each = var.aurora_mysql_parameters["instance"]
    iterator = instance
    content {
      name         = instance.value.name
      value        = instance.value.value
      apply_method = instance.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "tf101-aurora-instance-parameter"
  })
}


resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name        = "aurora-cluster-mysql8"
  family      = "aurora-mysql8.0"
  description = "DMS Test Parameter Group"

  dynamic "parameter" {
    for_each = var.aurora_mysql_parameters["cluster"]
    iterator = cluster
    content {
      name         = cluster.value.name
      value        = cluster.value.value
      apply_method = cluster.value.apply_method
    }
  }

  tags = merge(var.tags, {
    Name = "tf101-aurora-cluster-parameter"
  })
}
