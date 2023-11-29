###########################
#     Region 1 - Seoul    #
###########################
########################## VPC1 ######################
variable "networking_r1_a" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
    cidr_block      = "10.1.0.0/16"
    region          = "ap-northeast-2"
    vpc_name        = "eks-vpc"
    azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
    public_subnets  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    private_subnets = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
    nat_gateways    = true
  }
}

############################# VPC2 ##############################
variable "networking_r1_b" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
    cidr_block      = "172.20.0.0/16"
    region          = "ap-northeast-2"
    vpc_name        = "gitops-vpc"
    azs             = ["ap-northeast-2a"]
    public_subnets  = ["172.20.1.0/24"]
    private_subnets = ["172.20.2.0/24"]
    nat_gateways    = true
  }
}

###########################
#     Region 2 - Tokyo    #
###########################
########################## VPC1 ######################
variable "networking_r2_a" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
    cidr_block      = "10.2.0.0/16"
    region          = "ap-northeast-1"
    vpc_name        = "terraform-vpc"
    azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
    public_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
    private_subnets = ["10.2.10.0/24", "10.2.20.0/24", "10.2.30.0/24"]
    nat_gateways    = true
  }
}

############################# VPC2 ##############################
variable "networking_r2_b" {
  type = object({
    cidr_block      = string
    region          = string
    vpc_name        = string
    azs             = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
    nat_gateways    = bool
  })
  default = {
    cidr_block      = "172.30.0.0/16"
    region          = "ap-northeast-1"
    vpc_name        = "bastion-vpc"
    azs             = ["ap-northeast-1a"]
    public_subnets  = ["172.30.1.0/24"]
    private_subnets = ["172.30.2.0/24"]
    nat_gateways    = true
  }
}

############################# EKS ##############################
variable "cluster_config" {
  type = object({
    name    = string
    version = string
  })
  default = {
    name    = "eks-cluster"
    version = "1.23"
  }
}

variable "node_groups" {
  type = list(object({
    name           = string
    instance_types = list(string)
    ami_type       = string
    capacity_type  = string
    disk_size      = number
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })
    update_config = object({
      max_unavailable = number
    })
  }))
  default = [
    {
      name           = "t3-micro-standard"
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      scaling_config = {
        desired_size = 1
        max_size     = 4
        min_size     = 1
      }
      update_config = {
        max_unavailable = 1
      }
    },
  ]

}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "kube-proxy"
      version = "v1.22.6-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.11.0-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.1"
    },
    #{
    #  name    = "aws-ebs-csi-driver"
    #  version = "v1.6.2-eksbuild.0"
    #}
  ]
}

# ############################# ALB ##############################
# variable "target_group_setting" {
#   description = "lb target group setting"
#   type = map(string)
#   default = {
#     name = "albSetting"
#     port = "80"
#     algorithm_type = "least_outstanding_requests"
#   }
# }

# variable "aws_alb_tags" {
#   description = "Tags for the ALB"
#   type        = map(string)
#   default     = {
#     Name = "MyALB"
#     Environment = "Production"
#   }
# }



# variable "lb_target_group_tags" {
#   description = "Tags for the LB Target Group"
#   type        = map(string)
#   default     = {
#     Name = "MyTargetGroup"
#     Environment = "Production"
#   }
# }





