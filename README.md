# Terraform AWS Infra Script

### Introduction

---
Terraform 사용 방법을 학습하기 위한 각종 서비스 Resource를 모듈로 나누어 구성합니다. 백엔드는 현재 Local로 각 환경에서 관리하고 추후 Terraform Cloud와 Github을 통합하여 tfstate와 version control을 해보려 합니다.

Terraform Cloud에서 원격으로 Plan, Apply를 진행하기 때문에 AWS credentials 정보가 필요합니다. 좀더 보안적으로 관리할 방법 확인이 필요합니다.

다만 Terraform은 null처리에 대한 내용이 명확하지 않습니다. 내부의 optional 객체와 같은 형태로 구성되어 있기 때문에 애초에 null 자체를 허용하지 않습니다. 경우에 따라 null 입력 등에 대한 처리가 필요하기에 cdktf로 추후 마이그레이션 예정입니다.


### Default Architecture
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
├── main.tf ## main(global의 상태를 가져와서 data로 사용 가능한지 테스트를 해 보자...)
├── global ## backend를 위한 s3, dynamoDB 생성용 폴더(not module)
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
└── module ## module directory
    ├── eks ## eks cluster 구축
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── eks_istio ## kubernetes 접속및 istio helm 설치
    │   ├── main.tf
    ├── tf101_week3_rds ## 개발중...
    │   ├── secret_manager.tf
    │   ├── rds.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── tf101_week2_asg  ## tf101 study 2주차 alb와 asg, ec2를 활용한 간단한 웹 서버를 배포합니다.
    │   ├── launch_template.tf
    │   ├── iam.tf
    │   ├── asg.tf
    │   ├── alb.tf
    │   ├── output.tf
    │   └── variables.tf
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

### Requirement

---
##### CLI 설치 필요

* aws cli v2
  * ```brew install awscli```
* [pluralith](<https://www.pluralith.com/>)
* tfenv
  * terraform cli version 관리 툴

##### Install
This is the official guide for terraform binary installation. Please visit this [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) website and follow the instructions.

Or, you can manually get a specific version of terraform binary from the websiate. Move to the [Downloads](https://www.terraform.io/downloads.html) page and look for the appropriate package for your system. Download the selected zip archive package. Unzip and install terraform by navigating to a directory included in your system's `PATH`.

Or, you can use [tfenv](https://github.com/tfutils/tfenv) utility. It is very useful and easy solution to install and switch the multiple versions of terraform-cli.

First, install tfenv using brew.

```
brew install tfenv
```

Then, you can use tfenv in your workspace like below.

```
tfenv install <version>
tfenv use <version>
```

Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.

```
tfenv list
tfenv install latest
tfenv use <version>
```

### Terraform Cloud 인증키 발급

terraform status를 관리하기위하여 두가지 방식을 설정 해보고자 합니다.
1. terraform cloud
2. AWS s3, DynamoDB

##### 1. Terraform Cloud
우선 Terraform Cloud는 일부 무료로 어느정도 이용이 가능합니다. 세팅에 따라 클라우드 상에서 파이프라인을 구동할 수 있습니다(remote 옵션을 주어 Terraform Cloud에서 plan과 apply가 가능합니다). 이 기능은 git과 연동되어 특정 브런치에 push가 발생하면 수행하도록 처리 할 수 있습니다.
해당 workspace의 settings로 가서 Execution Mode와 Apply Method를 수정하여 적절하게 자동화 할 수 있습니다.

```bash
#terrafform cloud backend
terraform {
  backend "remote" {
    organization = "mate-sample"

    workspaces {
      name = "aws-iac-sample"
    }
  }
}
```

```bash
## 테라폼 로그인을 통하여 cloud 인증 토큰을 받아와 로컬 PC에 저장합니다.(추후 진행)
terraform login

## AWS configure를 설정합니다.
aws configure
## AWS SSO를 사용하는 경우
aws sso login --profile <profile name>
```
##### 2. S3, DynamoDB
S3를 Backend로 사용하는 경우 아래와 같은 설정으로 tfstate 파일 저장이 가능하다. s3의 prefix는 [bucket_name]/env:/[workspace_name]]/terraform/aws-iac-study/terraform.tfstate 형태로 만들어진다. 다만, s3만 사용하는경우 lock을 관리할수 없기 때문에 DynamoDB와 함께 사용해야한다. 이때 일관성에 대하여 신중하게 생각할 필요가 있다.
```bash
 backend "s3" {
    bucket         = "[bucket_name]"
    key            = "terraform/aws-iac-study/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    profile        = "sso-org-root"
    dynamodb_table = "[dynamodb_table_name]"
  }
```

### AWS credentials 발급

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

```hcl
provider "kubernetes" {
  alias                  = "eks-cluster"
  host                   = module.eks_cluster.host
  cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
  token                  = module.eks_cluster.token
}

provider "helm" {
  alias = "eks-cluster"
  kubernetes {
    host                   = module.eks_cluster.host
    cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
    token                  = module.eks_cluster.token
  }
}
```
* kubernetes와 helm provider를 추가하여 eks생성과 후 셋팅을 전부 할 수 있다.
* IAM 등록과 Add-on 설치는 작업중...

### Terraform workspace사용
```bash
##terraform workspace 생성
$ terraform workspace new sso-org-root
default
##terraform workspace list 출력
$ terraform workspace list
  default
  poc
  sso-org-poc
* sso-org-root
##terraform 현재 workspace 출력
$ terraform workspace show
sso-org-root
##terraform workspace 선택
$ terraform workspace select sso-org-root
Switched to workspace "sso-org-root".
```

### Terraform 명령 sample
**자주 사용하는 명령어 정리**

    1) pluralith plan
       1) pluralith를 사용하여 생성될 Architecture를 도식화 합니다
    2) terraform init
       1) terraform의 프로바이더와 모듈을 초기화 합니다
       2) 새로운 모듈이 추가되거나 프로바이더가 추가되는 경우 꼭 한번씩 실행해 줘야 합니다
    3) terraform plan
       1) 사전에 테라폼으로 실행될 리소스들의 의존관계를 검증합니다
    4) terraform validate
       1) 테라폼 파일의 형식을 검증합니다.
    5) terraform new workspace 
       1) poc poc라는 workspace를 만듭니다
       2) 각 workspace별로 다른 vars를 적용할 수 있도록 구성이 가능합니다
    6) terraform apply -auto-approve 
    7) terraform apply -target=module.security_group -auto-approve 
    8) terraform apply -target=module.vpc -auto-approve
       1) tfstate 파일은 개인만 사용하는 경우 local로 저장해도 무방하나 팀 단위로 작업시 backend를 생성하여 상태를 저장해 주는것을 추천합니다.
       2) 해당 파일은 내부적으로 AWS Cloud 인프라와 Terraform 소스상 바인딩 상태를 저장하기 때문에 분실또는 손상되는 경우 다시 매핑 시켜주는 작업이 필요합니다.
    9)  terraform destroy
       3) 모든 리소스 생성후 꼭 삭제해주셔야 합니다.
    10) terraform destroy --target module.week2_alb_asg --auto-approve
       4) 일부 리소스를 재 생성해야 하는경우 모듈만 별도로 삭제후 apply 진행할 수 있습니다.

**Terraform Cloud 백엔드 생성**
```bash
# terraform cloud 로그인후 다른 backend로 변경하려는 경우
# 아래와 같이 입력하면 이전에 설정한 state를 local로 다시 마이그레이션 합니다
terraform init -migrate-state
# 아래의 명령어를 입력하면 local에 다시 state를 생성합니다
# 삭제후 아래의 명령어를 입력하면 문제 없으나 이미 생성되어 있는 리소스가 있는 상태에서 아래의 명령어를 입력하면 충돌이 발생합니다
terraform init -reconfigure
```

**terraform -help 명령어 옵션 설명**

```bash

Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.
```

**TO-DO List**

- [x] EKS launch_template 생성
- [x] EKS Cluster 생성
- [ ] IRSA 구성
- [ ] 기본 서비스 배포
- [ ] cdktf로 컨버팅