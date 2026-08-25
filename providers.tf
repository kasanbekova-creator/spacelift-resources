provider "aws" {
  region = "us-west-2"
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

# TODO(spacelift): set kubernetes/helm provider auth once worker auth is decided
# (OIDC/AssumeRoleWithWebIdentity as primary, or IRSA/Pod Identity via Kyverno as fallback)
# Replace the token value below with the appropriate exec{} or token config for the Spacelift worker.
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = "PLACEHOLDER" # TODO(spacelift): replace with worker auth token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = "PLACEHOLDER" # TODO(spacelift): replace with worker auth token
  }
}
