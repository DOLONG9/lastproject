###########################
#     Region 1 - Seoul    #
###########################

####################   Create r1-vpc1   ####################
########## Network ##########
# VPC
resource "aws_vpc" "r1-vpc1" {
  cidr_block = var.networking_r1_a.cidr_block
  provider = aws.kr
  enable_dns_support   = true
  enable_dns_hostnames = true
  

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.networking_r1_a.vpc_name
  }
}


# Public Subnets
resource "aws_subnet" "vpc1_public_subnets" {
  provider = aws.kr
  count                   = length(var.networking_r1_a.public_subnets)
  vpc_id                  = aws_vpc.r1-vpc1.id
  cidr_block              = element(var.networking_r1_a.public_subnets, count.index)
  availability_zone       = element(var.networking_r1_a.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc1_public_subnet-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "vpc1_private_subnets" {
  provider = aws.kr
  count                   = length(var.networking_r1_a.private_subnets)
  vpc_id                  = aws_vpc.r1-vpc1.id
  cidr_block              = element(var.networking_r1_a.private_subnets, count.index)
  availability_zone       = element(var.networking_r1_a.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc1_private_subnet-${count.index}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "vpc1_igw" {
  provider = aws.kr
  vpc_id = aws_vpc.r1-vpc1.id

  tags = {
    Name = "vpc1_igw"
  }
}

# EIP
resource "aws_eip" "vpc1_eip" {
  provider = aws.kr
  domain     = "vpc"
  depends_on = [aws_internet_gateway.vpc1_igw]

  tags = {
    Name = "vpc1_eip"
  }
}

# NAT Gasteway
resource "aws_nat_gateway" "vpc1_nat_gw" {
  provider = aws.kr
  subnet_id         = element(aws_subnet.vpc1_public_subnets[*].id, 0)
  connectivity_type = "public"
  allocation_id     = aws_eip.vpc1_eip.id
  depends_on        = [aws_internet_gateway.vpc1_igw]

  tags = {
    Name = "vpc1_nat_gw"
  }
}

# Public Route Table
resource "aws_route_table" "vpc1_public_table" {
  provider = aws.kr
  vpc_id = aws_vpc.r1-vpc1.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }

  route{
    cidr_block = "172.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "vpc1_public_table"
  }

}

resource "aws_route_table_association" "vpc1_assoc_public_routes" {
  provider = aws.kr
  count          = length(aws_subnet.vpc1_public_subnets)
  subnet_id      = element(aws_subnet.vpc1_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.vpc1_public_table.id
}

# Private Route Table
resource "aws_route_table" "vpc1_private_table"{
  provider = aws.kr
  vpc_id = aws_vpc.r1-vpc1.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vpc1_nat_gw.id
  }

  route{
    cidr_block = "172.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "vpc1_private_table"
  }

  depends_on = [ aws_vpc_peering_connection.peer ]

}

resource "aws_route_table_association" "vpc1_assoc_private_route" {
  provider = aws.kr
  count          = length(aws_subnet.vpc1_private_subnets)
  subnet_id      = element(aws_subnet.vpc1_private_subnets[*].id, count.index)
  route_table_id = aws_route_table.vpc1_private_table.id
}




####################  Create r1-vpc2 ####################
########## Network ##########
# VPC
resource "aws_vpc" "r1-vpc2" {
  provider = aws.kr
  cidr_block = var.networking_r1_b.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.networking_r1_b.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "vpc2_public_subnets" {
  provider = aws.kr
  count                   = length(var.networking_r1_b.public_subnets)
  vpc_id                  = aws_vpc.r1-vpc2.id
  cidr_block              = element(var.networking_r1_b.public_subnets, count.index)
  availability_zone       = element(var.networking_r1_b.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc2_public_subnet-${count.index}"
  }
}

# Private Subnetes
resource "aws_subnet" "vpc2_private_subnets" {
  provider = aws.kr
  count                   = length(var.networking_r1_b.private_subnets)
  vpc_id                  = aws_vpc.r1-vpc2.id
  cidr_block              = element(var.networking_r1_b.private_subnets, count.index)
  availability_zone       = element(var.networking_r1_b.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc2_private_subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc2_igw" {
  provider = aws.kr
  vpc_id = aws_vpc.r1-vpc2.id

  tags = {
    Name = "vpc2_igw"
  }
}

# ########### EC2 할당이 없음으로 비용 절감을 위해 리소스 생성 X ###########
# # EIP
# resource "aws_eip" "vpc2_eip" {
#   provider = aws.kr
#   domain        = "vpc"
#   depends_on = [aws_internet_gateway.vpc2_igw]

#   tags = {
#     Name = "vpc2_eip"
#   }
# }

# # NAT Gateway
# resource "aws_nat_gateway" "vpc2_nat_gw" {
#   provider = aws.kr
#   subnet_id         = element(aws_subnet.vpc2_public_subnets[*].id, 0)
#   connectivity_type = "public"
#   allocation_id     = aws_eip.vpc2_eip.id
#   depends_on        = [aws_internet_gateway.vpc2_igw]

#   tags = {
#     Name = "vpc2_nat_gw"
#   }
# }

# Public Route Table
resource "aws_route_table" "vpc2_public_table" {
  provider = aws.kr
  vpc_id = aws_vpc.r1-vpc2.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2_igw.id
  }

  route{
    cidr_block = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "vpc2_public_table"
  }

  depends_on = [ aws_vpc_peering_connection.peer ]
}

resource "aws_route_table_association" "vpc2_assoc_public_routes" {
  provider = aws.kr
  count          = length(aws_subnet.vpc2_public_subnets)
  subnet_id      = element(aws_subnet.vpc2_public_subnets[*].id, count.index)
  route_table_id = aws_route_table.vpc2_public_table.id
}

# Private Route Table
resource "aws_route_table" "vpc2_private_table" {
  provider = aws.kr
  count  = length(var.networking_r1_b.azs)
  vpc_id = aws_vpc.r1-vpc2.id

  # route{
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.vpc2_nat_gw.id
  # }

  route{
    cidr_block = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "vpc2_private_table"
  }

  depends_on = [ aws_vpc_peering_connection.peer ]

}

resource "aws_route_table_association" "vpc2_assoc_private_route" {
  provider = aws.kr
  count          = length(aws_subnet.vpc2_private_subnets)
  subnet_id      = element(aws_subnet.vpc2_private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.vpc2_private_table[*].id, count.index)
}


########## VPC PEERING ##########
# VPC Peering Connection(bastion vpc - aws vpc )
resource "aws_vpc_peering_connection" "peer" {
  provider = aws.kr
  peer_owner_id = local.peer_owner_id
  peer_vpc_id   = aws_vpc.r1-vpc1.id
  vpc_id        = aws_vpc.r1-vpc2.id
  peer_region   = "ap-northeast-2"

  auto_accept   = false

  depends_on = [aws_vpc.r1-vpc1, aws_vpc.r1-vpc2]
}

# VPC Peering Connection Options
resource "aws_vpc_peering_connection_options" "peer" {
  provider = aws.kr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

  depends_on = [aws_vpc_peering_connection.peer]
}

# VPC Peering Connection Accept
resource "null_resource" "create-endpoint" {
  provisioner "local-exec" {
    command = "aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${aws_vpc_peering_connection.peer.id} --region ap-northeast-2"
  }
  depends_on = [aws_vpc_peering_connection.peer]
}



########## EC2 Key Pair ##########
resource "aws_key_pair" "r1_bastion" {
  provider = aws.kr
  key_name   = "BastionKeyPair"
  public_key = file("./keypair/bastion-key-pair.pub")
  tags = {
    description = "bastion host ec2 pub key"
  }
}
resource "aws_key_pair" "r1_cicd" {
  provider = aws.kr
  key_name   = "CICDKeyPair"
  public_key = file("./keypair/cicd-key-pair.pub")
  tags = {
    description = "cicd gitops ec2 pub key"
  }
}
resource "aws_key_pair" "r1_node" {
  provider = aws.kr
  key_name   = "NodeKeyPair"
  public_key = file("./keypair/node-key-pair.pub")
  tags = {
    description = "eks worker node ec2 pub key"
  }
}



########## EC2 Instance ##########
# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  provider = aws.kr
  name = "bastionhost security_group"
  vpc_id = aws_vpc.r1-vpc1.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "bastion-sg"
  }
  depends_on = [aws_vpc_peering_connection.peer]
}

# GitOps Security Group
resource "aws_security_group" "gitops-sg" {
  provider = aws.kr
  name = "gitops security_group"
  vpc_id = aws_vpc.r1-vpc2.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # gitlab, jenkins, harbor 
  ingress {
    from_port = 1000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # ALL from private subnet
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "gitops-sg"
  }
  depends_on = [aws_vpc_peering_connection.peer]
}

# GitOps EC2 EIP
resource "aws_eip" "gitops_eip" {
  provider = aws.kr
  domain     = "vpc"
  instance = aws_instance.public_gitops.id

  tags = {
    Name = "gitops_eip"
  }
}

# Bastion Host EC2
resource "aws_instance" "bastion" {
  provider = aws.kr
  ami           = "ami-0c9c942bd7bf113a2"
  instance_type = "t3.micro"
  subnet_id     = element(aws_subnet.vpc1_public_subnets[*].id, 0)
  key_name      = "BastionKeyPair"
  vpc_security_group_ids = [
    aws_security_group.bastion-sg.id
  ]

  tags = {
    "Name" = "EKS-bastionHostEC2"
  }

  depends_on = [ aws_key_pair.r1_bastion ]
}

# GitOps(CI/CD) EC2
resource "aws_instance" "public_gitops" {
  provider = aws.kr
  ami           = "ami-0c9c942bd7bf113a2"
  instance_type = "t3.large"
  subnet_id     = element(aws_subnet.vpc2_public_subnets[*].id, 0)
  key_name      = "CICDKeyPair"
  vpc_security_group_ids = [
    aws_security_group.gitops-sg.id
  ]

  root_block_device {
    volume_size = "30"
  }

  tags = {
    "Name" = "EKS-GitOpsEC2"
  }

  depends_on = [ aws_key_pair.r1_cicd ]
}


########## EBS ##########
# EBS
resource "aws_ebs_volume" "r1_gitops_ebs" {
  provider = aws.kr
  availability_zone = element(var.networking_r1_b.azs[*], 0)
  size              = 30

  tags = {
    Name = "r1_gitops_ebs"
  }
}

# ELB Volume Attachment
resource "aws_volume_attachment" "r1_gitops_ebs_att" {
  provider = aws.kr
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.r1_gitops_ebs.id
  instance_id = aws_instance.public_gitops.id
}


########## EKS ##########
# EKS Cluster
resource "aws_eks_cluster" "eks-cluster" {
  provider = aws.kr
  name     = var.cluster_config.name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_config.version

  vpc_config {
    subnet_ids         = flatten([aws_subnet.vpc1_private_subnets[*].id])
    security_group_ids = [aws_security_group.control-sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]

}

# Node Group
resource "aws_eks_node_group" "node-ec2" {
  provider = aws.kr
  for_each        = { for node_group in var.node_groups : node_group.name => node_group }
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = aws_subnet.vpc1_private_subnets[*].id


  scaling_config {
    desired_size = try(each.value.scaling_config.desired_size, 2)
    max_size     = try(each.value.scaling_config.max_size, 4)
    min_size     = try(each.value.scaling_config.min_size, 1)
  }

  update_config {
    max_unavailable = try(each.value.update_config.max_unavailable, 1)
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  remote_access {
    ec2_ssh_key               = "NodeKeyPair"
    source_security_group_ids = [aws_security_group.bastion-sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AutoScalingFullAccess,
    aws_key_pair.r1_node
  ]

  tags = {
    "Name" = "eks-node-group2"
  }
}


# Addons
resource "aws_eks_addon" "addons" {
  provider = aws.kr
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks-cluster.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# oidc
resource "aws_iam_openid_connect_provider" "default" {
  url             = "https://${local.oidc}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

# Control Plane Security Group
resource "aws_security_group" "control-sg" {
  provider = aws.kr
  name = "control-sg"
  vpc_id      = aws_vpc.r1-vpc1.id
  # Ingress rules
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion-sg.id]
  }

  # Egress rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc_peering_connection.peer]
}



#################### ROUTE 53 ####################
resource "aws_route53_zone" "public" {
  name = "kakao-commit.site"
}


###################################################################################################################################



###########################
#     Region 2 - Tokyo    #
###########################

####################   Create r2-vpc1   ####################
########## Network ##########
# VPC
resource "aws_vpc" "r2-vpc1" {
  cidr_block = var.networking_r2_a.cidr_block
  provider = aws.jp
  enable_dns_support   = true
  enable_dns_hostnames = true
  

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.networking_r2_a.vpc_name
  }
}


# Public Subnets
resource "aws_subnet" "vpc1_public_subnets2" {
  provider = aws.jp
  count                   = length(var.networking_r2_a.public_subnets)
  vpc_id                  = aws_vpc.r2-vpc1.id
  cidr_block              = element(var.networking_r2_a.public_subnets, count.index)
  availability_zone       = element(var.networking_r2_a.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc1_public_subnet2-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "vpc1_private_subnets2" {
  provider = aws.jp
  count                   = length(var.networking_r2_a.private_subnets)
  vpc_id                  = aws_vpc.r2-vpc1.id
  cidr_block              = element(var.networking_r2_a.private_subnets, count.index)
  availability_zone       = element(var.networking_r2_a.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc1_private_subnet2-${count.index}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "vpc1_igw2" {
  provider = aws.jp
  vpc_id = aws_vpc.r2-vpc1.id

  tags = {
    Name = "vpc1_igw2"
  }
}

# EIP
resource "aws_eip" "vpc1_eip2" {
  provider = aws.jp
  domain     = "vpc"
  depends_on = [aws_internet_gateway.vpc1_igw2]

  tags = {
    Name = "vpc1_eip2"
  }
}

# NAT Gasteway
resource "aws_nat_gateway" "vpc1_nat_gw2" {
  provider = aws.jp
  subnet_id         = element(aws_subnet.vpc1_public_subnets2[*].id, 0)
  connectivity_type = "public"
  allocation_id     = aws_eip.vpc1_eip2.id
  depends_on        = [aws_internet_gateway.vpc1_igw2]
}

# Public Route Table
resource "aws_route_table" "vpc1_public_table2" {
  provider = aws.jp
  vpc_id = aws_vpc.r2-vpc1.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw2.id
  }

  route{
    cidr_block = "172.30.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  }

  tags = {
    Name = "vpc1_public_table2"
  }

}

resource "aws_route_table_association" "vpc1_assoc_public_routes2" {
  provider = aws.jp
  count          = length(aws_subnet.vpc1_public_subnets2)
  subnet_id      = element(aws_subnet.vpc1_public_subnets2[*].id, count.index)
  route_table_id = aws_route_table.vpc1_public_table2.id
}

# Private Route Table
resource "aws_route_table" "vpc1_private_table2"{
  provider = aws.jp
  vpc_id = aws_vpc.r2-vpc1.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vpc1_nat_gw2.id
  }

  route{
    cidr_block = "172.30.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  }

  tags = {
    Name = "vpc1_private_table2"
  }

  depends_on = [ aws_vpc_peering_connection.peer2 ]

}

resource "aws_route_table_association" "vpc1_assoc_private_route2" {
  provider = aws.jp
  count          = length(aws_subnet.vpc1_private_subnets2)
  subnet_id      = element(aws_subnet.vpc1_private_subnets2[*].id, count.index)
  route_table_id = aws_route_table.vpc1_private_table2.id
}




####################  Create r2-vpc2 ####################
########## Network ##########
# VPC
resource "aws_vpc" "r2-vpc2" {
  provider = aws.jp
  cidr_block = var.networking_r2_b.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.networking_r2_b.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "vpc2_public_subnets2" {
  provider = aws.jp
  count                   = length(var.networking_r2_b.public_subnets)
  vpc_id                  = aws_vpc.r2-vpc2.id
  cidr_block              = element(var.networking_r2_b.public_subnets, count.index)
  availability_zone       = element(var.networking_r2_b.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc2_public_subnets2-${count.index}"
  }
}

# Private Subnetes
resource "aws_subnet" "vpc2_private_subnets2" {
  provider = aws.jp
  count                   = length(var.networking_r2_b.private_subnets)
  vpc_id                  = aws_vpc.r2-vpc2.id
  cidr_block              = element(var.networking_r2_b.private_subnets, count.index)
  availability_zone       = element(var.networking_r2_b.azs, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "vpc2_private_subnets2-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc2_igw2" {
  provider = aws.jp
  vpc_id = aws_vpc.r2-vpc2.id

  tags = {
    Name = "vpc2_igw2"
  }
}

# ########### EC2 할당이 없음으로 비용 절감을 위해 리소스 생성 X ###########
# # EIP
# resource "aws_eip" "vpc2_eip2" {
#   provider = aws.jp
#   domain        = "vpc"
#   depends_on = [aws_internet_gateway.vpc2_igw2]

#   tags = {
#     Name = "vpc2_eip2"
#   }
# }

# # NAT Gateway
# resource "aws_nat_gateway" "vpc2_nat_gw2" {
#   provider = aws.jp
#   subnet_id         = element(aws_subnet.vpc2_public_subnets2[*].id, 0)
#   connectivity_type = "public"
#   allocation_id     = aws_eip.vpc2_eip2.id
#   depends_on        = [aws_internet_gateway.vpc2_igw2]

#   tags = {
#     Name = "vpc2_nat_gw2"
#   }
# }

# Public Route Table
resource "aws_route_table" "vpc2_public_table2" {
  provider = aws.jp
  vpc_id = aws_vpc.r2-vpc2.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc2_igw2.id
  }

  route{
    cidr_block = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  }

  tags = {
    Name = "vpc2_public_table"
  }

  depends_on = [ aws_vpc_peering_connection.peer2 ]
}

resource "aws_route_table_association" "vpc2_assoc_public_routes2" {
  provider = aws.jp
  count          = length(aws_subnet.vpc2_public_subnets2)
  subnet_id      = element(aws_subnet.vpc2_public_subnets2[*].id, count.index)
  route_table_id = aws_route_table.vpc2_public_table2.id
}

# Private Route Table
resource "aws_route_table" "vpc2_private_table2" {
  provider = aws.jp
  count  = length(var.networking_r2_b.azs)
  vpc_id = aws_vpc.r2-vpc2.id

  # route{
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.vpc2_nat_gw2.id
  # }

  route{
    cidr_block = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  }

  tags = {
    Name = "vpc2_private_table"
  }

  depends_on = [ aws_vpc_peering_connection.peer2 ]

}

resource "aws_route_table_association" "vpc2_assoc_private_route2" {
  provider = aws.jp
  count          = length(aws_subnet.vpc2_private_subnets2)
  subnet_id      = element(aws_subnet.vpc2_private_subnets2[*].id, count.index)
  route_table_id = element(aws_route_table.vpc2_private_table2[*].id, count.index)
}


########## VPC PEERING ##########
# VPC Peering Connection(bastion vpc - aws vpc )
resource "aws_vpc_peering_connection" "peer2" {
  provider = aws.jp
  peer_owner_id = local.peer_owner_id
  peer_vpc_id   = aws_vpc.r2-vpc1.id
  vpc_id        = aws_vpc.r2-vpc2.id
  peer_region   = "ap-northeast-1"

  auto_accept   = false

  depends_on = [aws_vpc.r2-vpc1, aws_vpc.r2-vpc2]
}

# VPC Peering Connection Options
resource "aws_vpc_peering_connection_options" "peer2" {
  provider = aws.jp
  vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id

  depends_on = [aws_vpc_peering_connection.peer2]
}

# VPC Peering Connection Accept
resource "null_resource" "create-endpoint2" {
  provisioner "local-exec" {
    command = "aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${aws_vpc_peering_connection.peer2.id} --region ap-northeast-1"
  }
  depends_on = [aws_vpc_peering_connection.peer2]
}


########## EC2 Key Pair ##########
resource "aws_key_pair" "r2_bastion" {
  provider = aws.jp
  key_name   = "BastionKeyPair"
  public_key = file("./keypair/bastion-key-pair.pub")
  tags = {
    description = "bastion host ec2 pub key"
  }
}
resource "aws_key_pair" "r2_cicd" {
  provider = aws.jp
  key_name   = "CICDKeyPair"
  public_key = file("./keypair/cicd-key-pair.pub")
  tags = {
    description = "cicd gitops ec2 pub key"
  }
}
resource "aws_key_pair" "r2_node" {
  provider = aws.jp
  key_name   = "NodeKeyPair"
  public_key = file("./keypair/node-key-pair.pub")
  tags = {
    description = "eks worker node ec2 pub key"
  }
}


########## EC2 Instance ##########
# Bastion Security Group
resource "aws_security_group" "bastion-sg2" {
  provider = aws.jp
  name = "bastionhost security_group"
  vpc_id = aws_vpc.r2-vpc1.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "bastion-sg2"
  }
  depends_on = [aws_vpc_peering_connection.peer2]
}

# GitOps Security Group
resource "aws_security_group" "gitops-sg2" {
  provider = aws.jp
  name = "gitops security_group2"
  vpc_id = aws_vpc.r2-vpc2.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # gitlab, jenkins, harbor 
  ingress {
    from_port = 1000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALL from private subnet
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.2.10.0/24", "10.2.20.0/24", "10.2.30.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "gitops-sg2"
  }
  depends_on = [aws_vpc_peering_connection.peer2]
}


# GitOps EC2 EIP
resource "aws_eip" "gitops_eip2" {
  provider = aws.jp
  domain     = "vpc"
  instance = aws_instance.public_gitops2.id

  tags = {
    Name = "gitops_eip2"
  }
}


# Bastion Host EC2
resource "aws_instance" "bastion2" {
  provider = aws.jp
  ami           = "ami-0d52744d6551d851e"
  instance_type = "t3.micro"
  subnet_id     = element(aws_subnet.vpc1_public_subnets2[*].id, 0)
  key_name      = "BastionKeyPair"
  vpc_security_group_ids = [
    aws_security_group.bastion-sg2.id
  ]

  tags = {
    "Name" = "EKS-bastionHostEC2"
  }
  depends_on = [ aws_key_pair.r2_bastion ]
}

# GitOps(CI/CD) EC2
resource "aws_instance" "public_gitops2" {
  provider = aws.jp
  ami           = "ami-0d52744d6551d851e"
  instance_type = "t3.large"
  subnet_id     = element(aws_subnet.vpc2_public_subnets2[*].id, 0)
  key_name      = "CICDKeyPair"
  vpc_security_group_ids = [
    aws_security_group.gitops-sg2.id
  ]

  root_block_device {
    volume_size = "30"
  }

  tags = {
    "Name" = "EKS-GitOpsEC2"
  }
  depends_on = [ aws_key_pair.r2_cicd ]
}

########## EBS ##########
# EBS
resource "aws_ebs_volume" "r2_gitops_ebs" {
  provider = aws.jp
  availability_zone = element(var.networking_r2_b.azs[*], 0)
  size              = 30

  tags = {
    Name = "r2_gitops_ebs"
  }
}

# ELB Volume Attachment
resource "aws_volume_attachment" "r2_gitops_ebs_att" {
  provider = aws.jp
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.r2_gitops_ebs.id
  instance_id = aws_instance.public_gitops2.id
}


########## EKS ##########
# EKS Cluster
resource "aws_eks_cluster" "eks-cluster2" {
  provider = aws.jp
  name     = var.cluster_config.name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_config.version

  vpc_config {
    subnet_ids         = flatten([aws_subnet.vpc1_private_subnets2[*].id])
    security_group_ids = [aws_security_group.control-sg2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]

}

# Node Group
resource "aws_eks_node_group" "node-ec2-2" {
  provider = aws.jp
  for_each        = { for node_group in var.node_groups : node_group.name => node_group }
  cluster_name    = aws_eks_cluster.eks-cluster2.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = aws_subnet.vpc1_private_subnets2[*].id


  scaling_config {
    desired_size = try(each.value.scaling_config.desired_size, 2)
    max_size     = try(each.value.scaling_config.max_size, 4)
    min_size     = try(each.value.scaling_config.min_size, 1)
  }

  update_config {
    max_unavailable = try(each.value.update_config.max_unavailable, 1)
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size

  remote_access {
    ec2_ssh_key               = "NodeKeyPair"
    source_security_group_ids = [aws_security_group.bastion-sg2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AutoScalingFullAccess,
    aws_key_pair.r2_node
  ]

  tags = {
    "Name" = "eks-node-group2"
  }
}



resource "aws_eks_addon" "addons2" {
  provider = aws.jp
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks-cluster2.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  timeouts {
    create = "30m"
    delete = "30m"
  }
}


# Control Plane Security Group
resource "aws_security_group" "control-sg2" {
  provider = aws.jp
  name = "control-sg2"
  vpc_id      = aws_vpc.r2-vpc1.id
  # Ingress rules
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion-sg2.id]
  }

  # Egress rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc_peering_connection.peer2]
}