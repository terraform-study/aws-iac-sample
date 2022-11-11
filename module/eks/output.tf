output "host" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
}

output "token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "kubeconfig_filename" {
  value = local_file.kubeconfig.filename
}
