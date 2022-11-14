################################################################################
# EKS Cluster
################################################################################

resource "aws_iam_role" "eks_cluster" {
  name = "EKSClusterRole_${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_cloudwatch_log_group" "this" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 1
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

################################################################################
# EKS Node Group
################################################################################

resource "aws_iam_role" "eks_node" {
  name = "EKSNodeRole_${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node.name
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.node_group_instance_types

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = var.node_group_max_unavailable
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore
  ]
}


################################################################################
# Authentication
################################################################################

data "aws_eks_cluster_auth" "this" {
  name   = var.cluster_name
}

resource "local_file" "kubeconfig" {
  filename        = "kubeconfig.${var.cluster_name}"
  file_permission = "0600"
  content = yamlencode({
    apiVersion = "v1"
    clusters = [
      {
        cluster = {
          "certificate-authority-data" = aws_eks_cluster.this.certificate_authority[0].data
          server                       = aws_eks_cluster.this.endpoint
        }
        name = aws_eks_cluster.this.arn
      }
    ]
    contexts = [
      {
        context = {
          cluster = aws_eks_cluster.this.arn
          user    = aws_eks_cluster.this.arn
        }
        name = aws_eks_cluster.this.arn
      }
    ]
    "current-context" = aws_eks_cluster.this.arn
    kind              = "Config"
    preferences       = {}
    users = [
      {
        name = aws_eks_cluster.this.arn
        user = {
          exec = {
            apiVersion = "client.authentication.k8s.io/v1beta1"
            command    = "aws"
            args       = ["--region", var.region, "eks", "get-token", "--cluster-name", var.cluster_name]
          }
        }
      }
    ]
  })
}
