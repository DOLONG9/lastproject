data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks-cluster" {
  name = aws_eks_cluster.eks-cluster.name
}

############ 지역변수 ############
locals {
  oidc = trimprefix(data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer, "https://")
}

# 현재 계정의 리전 리소스를 리전 지역 변수로 설정
locals {
  region = data.aws_region.current.name
}
# VPC 피어링을 할 VPC 소유자(계정 - root, user1 등)의 계정 ID 을 지역 변수로 설정
locals {
  peer_owner_id = data.aws_caller_identity.current.account_id
}