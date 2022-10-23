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
├── tf101_week2_asg ## tf101 study 2주차 alb와 asg, ec2를 활용한 간단한 웹 서버를 배포합니다.
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

#### Requirement

---
**CLI 설치 필요**

* aws cli v2
  * ```brew install awscli```
* [pluralith](<https://www.pluralith.com/>)
* tfenv
  * terraform cli version 관리 툴

**Install**
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

**Terraform Cloud 인증키 발급**

terraform status를 관리하기위하여 두가지 방식을 설정 해보고자 합니다.
1. terraform cloud
2. AWS s3, DynamoDB

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
   
    # 서비스 Infra 구성 후, 필요한 경우, [Launch Config 백업] 및 [기타 Alarm 생성] 등을 수행한다.
    # EKS의 경우 Launch Template를 사용하는 경우 별도 작업이 필요합니다.
    # EKS Cluster에 Ingress를 연결하기 위해선 eksctl을 통해 별도 작업이 필요합니다.
        아직 cdk처럼 eks resource를 하나의 파이프라인으로 만들수 없습니다. 프로바이더를 변경하여 작업이 가능합니다


```bash
terraform -help
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