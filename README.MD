# README #

# How to run?

1. Update your terraform account credentials in ~/.aws/credentials with profile name terraform
2. Run `terraform init`
3. Run `terraform workspace new dev` (or prod)
4. Run `terraform plan && terraform apply`

## What is this repository for? ##

- Creating resources for dev/prod VPC

### VPC
| VPC Name       | IPv4 CIDR      |
|----------------|----------------|
| aws-eks-dev    | 100.101.0.0/16 |
| aws-eks-prod   | 100.102.0.0/16 |

### Subnet Design
- Zone A: 
  - public: 10.101.0.0/20
  - private: 10.101.16.0/20
- Zone B:
  - public: 10.101.0.0/20
  - private: 10.101.16.0/20
- Zone C: 10.2.128.0/18
  - public: 10.101.0.0/20
  - private: 10.101.16.0/20
    
### Route Table
| Route Table Name  | Subnet Associate                           | Destination                               | Target                                         |
|-------------------|--------------------------------------------|-------------------------------------------|------------------------------------------------|
| public-rt | public-subnet-1a<br/>public-subnet-1b<br/>public-subnet-1c|10.101.0.0/16<br/>0.0.0.0/0|local<br/>internet gateway|
| private-rt | private-subnet-1a<br/>private-subnet-1b<br/>private-subnet-1c|10.101.0.0/16<br/>0.0.0.0/0|local<br/>nat gateway|

## EKS cluster
| EKS Name       | 
|----------------|
| aws-eks-dev    | 
| aws-eks-prod   | 

- kubernetes_version: 1.21
- vpc_cni_version: v1.9.3-eksbuild.1
- coredns_version: v1.8.4-eksbuild.1
- kube_proxy_version: v1.21.2-eksbuild.2
- node group: workers