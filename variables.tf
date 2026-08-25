variable "eks_cluster_name" {
  description = "Existing EKS cluster to deploy Kubernetes resources into."
  type        = string
  default     = "dvtl815-poc"
}

variable "namespace" {
  description = "Namespace for the PoC and the kube-state-metrics release."
  type        = string
  default     = "spacelift-poc-tfc-replacement"
}

variable "app_namespace" {
  description = "Namespace for the placeholder web app."
  type        = string
  default     = "spacelift-dvtl815-app"
}

variable "app_name" {
  description = "Name for the app Deployment, its pod label, Service, and (as <name>-alb) the Ingress."
  type        = string
  default     = "hello"
}

variable "app_image" {
  description = "Container image without tag; app_image_tag selects the SHA."
  type        = string
  default     = "355433853014.dkr.ecr.us-west-2.amazonaws.com/spacelift-dvtl815-app"
}

variable "app_image_tag" {
  description = "Immutable git-SHA tag of the app image to deploy. Set by dvtl-815-app via image_tag.auto.tfvars."
  type        = string
  default     = "bootstrap"
}

variable "app_container_port" {
  description = "Port the app listens on. 8080 because the non-root distroless user can't bind <1024."
  type        = number
  default     = 8080
}

variable "app_service_port" {
  description = "Service port and Ingress backend target (80; ALB fronts 80->443)."
  type        = number
  default     = 80
}

variable "app_replicas" {
  description = "Number of app Deployment replicas."
  type        = number
  default     = 2
}

variable "app_alb_subnet_ids" {
  description = "Routable internal subnet IDs for app's internal ALB"
  type        = string
  default     = "subnet-06a15436cabfc17b2,subnet-0cbaa58a8949bf2b3,subnet-095d9900c9ab2b91f"
}

variable "app_hostname" {
  description = "App DNS hostname written to the private Route53 zone by external-dns-private. Convention: <app>.<account-id>.natera.io."
  type        = string
  default     = "spacelift-dvtl815.355433853014.natera.io"
}
