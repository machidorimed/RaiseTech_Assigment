## GitHub Actions × Ansible によるCI/CD環境構築

---

# 概要
このポートフォリオは、**Terraform** によるAWSインフラ構築と **Ansible** による構成管理を **GitHub Actions** によるCI/CDパイプラインから実行することで、「ファイルをpull requestすれば自動でテストを行い、pushするだけでアプリケーションを含めたAWSインフラ環境が出来上がる」状態まで完全自動実行する基本設計書となります。 

## 基本設計・ワークフロー
今回、Terraformの **modules機能** により、環境を*prod*と*stage*の２つ用意してます。
『pushされると、まず*stage*環境がデプロイ、アプリケーション起動まで問題なく動くことを確認し、メンバーの承認を得た後に*prod*環境がデプロイ、アプリケーションが起動する』構成にしています。
今回構成するワークフローは以下の通りです。

1\. `*.tf`ファイルや`.github/workflows/*.yaml`ファイルの変更をGitHubにプッシュ。

2\. GitHubのmainブランチにプルリクエストを送ると*stage*ディレクトリ内で自動で **terraform test** 実行。

3\. mainブランチにマージすることで自動で **terraform apply** を実行し*stage*環境構築。

4\. その後作成した*stage*環境のEC2に対しansibleを実行し、自動でアプリケーションをインストール。

5\. *stage*環境が正常に動作することを確認し、Github上で **environment** 操作を行うことで*prod*環境構築。

6\. 同様に作成した*prod*環境のEC2に対しansibleを実行し、自動でアプリケーションをインストール。

7\. ブラウザ上で `http://<EC2_IP>:8080`もしくは`http://< ALBのDNS名>`にアクセスし動作確認。

## インフラ構成図
<img width="1111" height="669" alt="スクリーンショット 2026-04-13 19 10 43" src="https://github.com/user-attachments/assets/f1df7158-75c7-426d-b968-dd1b7ee57085" />


---

## 全体構成
**リージョン**
- **東京リージョン (ap-northeast-1)** を使用。
  
**アベイラビリティゾーン（AZ）**
- **Multi-AZ (ap-northeast-1a,1c)** 構成とする。
  
**VPC**
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| 環境     | *Prod*/*stage*      | 
| 名前           | `aws-study-prodvpc`/`aws-study-stagevpc`        | 
| CIDRブロック       |  `10.0.0.0/16`/`172.16.0.0/16`       | 
| DNSホスト名解決 | 有効 | 
| DNS解決 | 有効 | 

**Public Subnet**
- *prod*
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| アベイラビリティゾーン      |  `ap-northeast-1a`/`ap-northeast-1c`       | 
| 名前           | `aws-study-prodpubsub-A`/`aws-study-prodpubsub-C`        | 
| CIDRブロック       |  `10.0.1.0/24`/`10.0.3.0/24`       | 
| IPアドレス割り当て | 有効 | 
- *stage*
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| アベイラビリティゾーン      |  `ap-northeast-1a`/`ap-northeast-1c`       | 
| 名前           | `aws-study-stagepubsub-A`/`aws-study-stagepubsub-C`        | 
| CIDRブロック       |  `172.16.1.0/24`/`172.16.3.0/24`       | 
| IPアドレス割り当て | 有効 | 

**Private Sunbet**
- *prod*
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| アベイラビリティゾーン      |  `ap-northeast-1a`/`ap-northeast-1c`       | 
| 名前           | `aws-study-prodprisub-A`/`aws-study-prodprisub-C`        | 
| CIDRブロック       |  `10.0.2.0/24`/`10.0.4.0/24`       | 
| IPアドレス割り当て | 無効 | 
- *stage*
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| アベイラビリティゾーン      |  `ap-northeast-1a`/`ap-northeast-1c`       | 
| 名前           | `aws-study-stageprisub-A`/`aws-study-stageprisub-C`        | 
| CIDRブロック       |  `172.16.2.0/24`/`172.16.4.0/24`       | 
| IPアドレス割り当て | 無効 | 

**インターネットゲートウェイ(IGW)**
- VPCに1つアタッチし、パブリックサブネットからのインターネットアクセスを可能にする。
- 名前: `aws-study-prodigw`(prod),`aws-study-stageigw`(stage)

**ルートテーブル**
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| 環境     | *Prod*/*stage*      | 
| 名前           | `aws-study-prodrtb`/`aws-study-stagertb`        | 
| 関連付けるサブネット       |  `Public Subnet`      | 
| ルーティングルール | `0.0.0.0/0` -> `igw` | 

**EC2インスタンス**
| 項目                             | 設定値                   |
| :-------------------- | :----------------------: | 
| 環境     | *Prod*/*stage*      | 
| 名前           | `aws-study-prodec2`/`aws-study-stageec2`        | 
| インスタンスタイプ       |  `t3.micro`      | 
| AMI | `ami-070d2b24928913a49`(Amazon Linux 2023) | 
| 配置サブネット      |  `aws-study-prodpubsub-A`/ `aws-study-stagepubsub-A`     | 
| Security Group | `aws-study-prodec2sg`/`aws-study-stageec2sg` | 
| アクセス方法       |  **SSM Session Manager**      | 
| IAM Role       |  `aws-study-prod-ssm-role`/`aws-study-stage-ssm-role`    | 
| EBSボリュームタイプ| `gp2` | 
| EBSボリュームサイズ     | `20` GiB      | 
| IPアドレス取得| 有効 | 
| 削除保護       |  無効      | 

**RDS**
| 項目                     | 説明 |
| :----------------------- | :--: |
| 環境     | *Prod*/*stage*      | 
| 名前           | `aws-study-prodrds`/`aws-study-stagerds`        | 
| DBエンジン               |   `MySQL 8.0.41`   |
| DBインスタンスクラス     |   `db.t4g.micro`   |
| 配置サブネットグループ   |   `aws-study-proddbsg`/`aws-study-stagedbsg`    |
| Multi-AZ配置            |   無効   |
| DB名                     |   `awsstudy`   |
| DBユーザー名       |   **GitHub Secretsで管理**   |
| DBパスワード       |   **GitHub Secretsで管理**   |
| ストレージタイプ         |   `gp2`   |
| ストレージサイズ    | `20` GiB    | 
| ストレージ暗号化         |   有効   |
| 自動バックアップ         |   有効（1日）   |
| Security Group           |   `aws-study-prodrdssg`/`aws-study-stagerdssg`    |
| 削除保護                 |   無効   |

**ALB**
| 項目                                   | 説明 |
| :------------------------------------- | :--: |
| 環境     | *Prod*/*stage*      | 
| 名前           | `aws-study-prodalb`/`aws-study-stagealb`        | 
| スキーム                               |   Internet-facing   |
| IPアドレスタイプ                       |   IPv4   |
| 配置サブネット                         |   Public Subnets   |
| Security Group                         |   `aws-study-prodalbsg`/`aws-study-stagealbsg`    |
| リスナー.                               |   `HTTP:80`   |
| ├ プロトコル                           |   HTTP   |
| ├ ポート                               |    80  |
| ターゲットグループ                     |   `aws-study-prodtg`/`aws-study-stagetg`   |
| ├ ターゲットタイプ                     |   Instance   |
| ├ プロトコル                           |   HTTP   |
| ├ ポート                               |   8080   |
| ├ ヘルスチェック                       |   正常コード`200,300,301`   |
| ├ ターゲット                           |   `aws-study-prodec2`/`aws-study-stageec2`    |
| WAF連携                                |   有り   |

**Security Group**
- ステートフルファイアウォール。許可する通信のみを定義。デフォルトDeny。
|  SG名           | 関連リソース |Inbound ルール (Source -> Port) |Outbound ルール (Dest -> Port) |
| :------------------------------------- | :--: |:--: |:--: |
| `aws-study-**albsg` | ALB |`0.0.0.0/0` -> `80` (HTTP)  |(デフォルト: ALL) |
| `aws-study-**ec2sg` | EC2 |`aws-study-**alb` -> `8080` (HTTP1)  |(デフォルト: ALL)|
| `aws-study-**dbsg` | RDS |`aws-study-**ec2sg` -> `3306` (TCP) |(デフォルト: ALL)|

**AWS WAF**
- 適用対象: ALB
- WebACL名: `aws-study-prodalb-waf`(prod),`aws-study-stagealb-waf`(stage)
- デフォルトアクション: Block
- ルール:
    - カスタムルール
        - `IPAddressWhitelistRule`: 指定したIPアドレスからの通信を許可する。
- ログ: CloudWatch Logs Log Group(`aws-waf-logs-study-***alb`)に出力。

**CloudWatch Alarm**
| 項目                                   | 説明 |
| :------------------------------------- | :--: |
| 環境     | *Prod*/*stage*      | 
| 名称           | `aws-study-***-cpu-utilization-alarm`     | 
| メトリクス                               |   `CPUUtilization`   |
| 対象                       |   `aws-study-prodec2`/`aws-study-stageec2`    |
| 閾値                      |   `80%`(60秒間平均)    |
| アクション                      |   SNSへ通知    |

**Amazon SNS**
- CloudWatch Alarmで闢値を超えた場合、Emailへ通知。
- 名前： `aws-study-prod-topic`(prod),`aws-study-stage-topic`(stage)
- 通知先Email: **GitHub Secretsで管理** 

**CloudWatch Logs・S3**
|  名称           | リソース名 |説明 |
| :------------------------------------- | :--: |:--: |
| `aws-waf-logs-study-***alb` | CloudWatch Logs |WAFログ保管用 |
| `aws-study-marube23-backet` | S3 |tfstateファイル保管用  |
| `aws-study-ansible-***-marube23-bucket` | S3 |Ansibleモジュール一時保管用 |

**IAM**
- ポリシー:
    - CloudWatch Logs にWAFログ収集に必要なリソースベースポリシーを付与。
- ロール:
    - EC2インスタンスにはSSM接続やS3アクセス権限を持つIAMロールをアタッチし、アクセスキーを使用しない。

---

### 開発環境
| 項目 | 説明 |
| :-------------------- | :----------------------: | 
| インフラ構築(IaC) | Terraform 1.14.7 |
| 構成管理 | Ansible 2.16.6 |
| CI/CD | GitHub Actions |
| 使用端末 | MacBook Air 2017 |
| 開発環境 | VSCode / GitHub / Tarminal / AWS CLI |

### 対象システム
| 項目                             | 説明                    |
| :-------------------- | :----------------------: | 
| アプリケーション       | RaiseTech学習用サンプルアプリケーション        | 
| 使用言語・ランタイム           | Java 21 (Amazon Corretto)         | 
| ビルドツール        |  Gradle 9.4.1      | 
| フレームワーク | Spring Boot 4.0.5 | 
| データベース | MySQL 8.0.41 | 

---

## リポジトリ構成

```bash
.
├── .github/workflows/
│   └── terraform.yaml              # CI/CD 実行ファイル
├── ansible/
│   ├── playbook.yaml
│   └── roles/
│       ├── common/                 # Java, git インストール
│       ├── mysql/                  # MySQL インストール
│       ├── app/                    # App clone + build
│       └── deploy/                 # systemd 準備 + 起動
├── modules/
│   ├── network/
│   │   ├── main.tf                 # VPC,IGW,Subnet
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── compute/
│   │   ├── main.tf                 # ALB,EC2,SSM
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── database/
│   │   ├── main.tf                 # RDS
│   │   ├── variables.tf
│   │   └── output.tf
│   ├── monitoring/
│   │   ├── main.tf                 # CloudWatch Alarm,Logs,S3,SNS
│   │   ├── variables.tf
│   │   └── output.tf
│   └── security/
│       ├── main.tf                 # WAF
│       ├── variables.tf
│       └── output.tf
└── envs/
    ├── prod/
    │   ├── main.tf                 # プロバイダー設定
    │   ├── main.tftest.hcl         # テスト用ファイル
    │   ├── outputs.tf              # 出力値定義
    │   ├── terraform.tfvars        # サンプル変数ファイル
    │   └── variables.tf            # 変数定義
    └── stage/
        ├── main.tf                 # プロバイダー設定
        ├── main.tftest.hcl         # テスト用ファイル
        ├── outputs.tf              # 出力値定義
        ├── terraform.tfvars        # サンプル変数ファイル
        └── variables.tf            # 変数定義
```
---
