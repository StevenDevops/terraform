module "vpc" {
  source        = "./modules/vpc"
  eks_disk_size = 20
  network_name  = format("aws-eks-%s", terraform.workspace)
  cidr_block    = local.cidr_block[terraform.workspace]
  user_name     = "steven"

  subnets = {
    "eu-west-1a" : {
      "public" : [4, 0],  // 10.101.0.0/20
      "private" : [4, 1], // 10.101.16.0/20
    },
    "eu-west-1b" : {
      "public" : [4, 4],  // 10.101.64.0/20
      "private" : [4, 5]  // 10.101.80.0/20
    },
    "eu-west-1c" : {
      "public" : [4, 8],  // 10.101.128.0/20
      "private" : [4, 9]  // 10.101.144.0/20
    }
  }

  kubernetes_version = "1.21"
  vpc_cni_version    = "v1.9.3-eksbuild.1"
  coredns_version    = "v1.8.4-eksbuild.1"
  kube_proxy_version = "v1.21.2-eksbuild.2"
}
