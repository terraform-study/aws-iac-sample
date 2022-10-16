# Terraform AWS Infra Script

#### Introduction

---
Terraform 사용 방법을 학습하기 위한 각종 서비스 Resource를 모듈로 나누어 구성합니다. 백엔드는 현재 Local로 각 환경에서 관리하고 추후 Terraform Cloud와 Github을 통합하여 tfstate와 version control을 해보려 합니다.

Terraform Cloud에서 원격으로 Plan, Apply를 진행하기 때문에 AWS credentials 정보가 필요합니다. 좀더 보안적으로 관리할 방법 확인이 필요합니다.


#### Default Architecture
---
[pluralith를 활용한 Visualise Terraform Infrastructure](https://www.pluralith.com/)
예정

##### Direct tree
```bash
.
├── terraform.auto.tfvars ## -var옵션을 주면 override합니다.
├── terraform.auto.tfvars.json ## json type의 tfvars
├── variables.tf
├── README.md
├── main.tf ## main
├── tf101_week1_ec2 ## tf101 study 1주차
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
├── sg ## 공통 SG그룹 생성 모듈
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
└── vpc
    ├── main.tf
    ├── output.tf
    └── variables.tf
```

#### Requirement

---
**CLI 설치 필요**

* aws cli v2
* terraform
* tfenv
  * terraform cli version 관리 툴

**Terraform Cloud 인증키 발급**

```bash
## 테라폼 로그인을 통하여 cloud 인증 토큰을 받아와 로컬 PC에 저장합니다.(추후 진행)
terraform login

## AWS configure를 설정합니다.
aws configure
```

**AWS credentials 발급**

* 전체 리소스를 생성하기 때문에 우선 Administrator 권한으로 진행하겠습니다
```bash
[default]
aws_access_key_id = ******
aws_secret_access_key = ******

[poc]
role_arn = arn:aws:iam::******:role/******
source_profile = default
```
* Credentials은 위와 같이 교차 계정으로 처리했습니다. Default profile은 assume role만 가지고 있습니다.
* Code에 Credentials을 하드코딩으로 작성하는것은 최대한 지양해야합니다.
* profile의 정보를 가져오도록 작성하였고 workspace에 따라 환경을 분리하였습니다.(멀티계정의 경우)
```hcl
provider "aws" {
  region  = var.region
  alias   = "poc"
  profile = terraform.workspace == "default" ? "poc" : terraform.workspace
}

provider "aws" {
  region  = var.region
  alias   = "sso-org-root"
  profile = terraform.workspace == "sso-org-root" ? "sso-org-root" : terraform.workspace
}
```
* alias를 통해서 여러개의 provider를 지원하여 여러 모듈을 동시에 배포 및 관리할 수 있습니다.

#### Terraform 명령 sample

    1) terraform new workspace poc
    2) terraform init
    3) terraform apply -auto-approve 
    4) terraform apply -target=module.security_group -auto-approve 
    5) terraform apply -target=module.vpc -auto-approve
       1) tfstate 파일은 개인만 사용하는 경우 local로 저장해도 무방하나 팀 단위로 작업시 backend를 생성하여 상태를 저장해 주는것을 추천합니다.
       2) 해당 파일은 내부적으로 AWS Cloud 인프라와 Terraform 소스상 바인딩 상태를 저장하기 때문에 분실또는 손상되는 경우 다시 매핑 시켜주는 작업이 필요합니다.
    6) terraform destroy
       1) 모든 리소스 생성후 꼭 삭제해주셔야 합니다.
   
    # 서비스 Infra 구성 후, 필요한 경우, [Launch Config 백업] 및 [기타 Alarm 생성] 등을 수행한다.
    # EKS의 경우 Launch Template를 사용하는 경우 별도 작업이 필요합니다.
    # EKS Cluster에 Ingress를 연결하기 위해선 eksctl을 통해 별도 작업이 필요합니다.
        아직 cdk처럼 eks resource를 하나의 파이프라인으로 만들수 없습니다. 프로바이더를 변경하여 작업이 가능합니다.

```bash
