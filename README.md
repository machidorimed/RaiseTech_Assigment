## GitHub Actions × Ansible によるCI/CD環境構築

---

# 概要
このポートフォリオは、**Terraform** によるAWSインフラ構築と **Ansible** による構成管理を **GitHub Actions** によるCI/CDパイプラインから実行することで、「ファイルをpull requestすれば自動でテストを行い、pushするだけでアプリケーションを含めたAWSインフラ環境が出来上がる」状態まで完全自動実行する基本設計書となります。

## 技術選定
**インフラプロビジョニング（IaC）**
- Terraformを採用
  - インフラ構成をコード化することで再現性と変更管理を担保するため  
  - 複数環境（*prod*・*stage*）への展開を容易にするため  
  - CloudFormationも検討したが、マルチサービス対応や拡張性を考慮しTerraformを選定

**デプロイ（CI/CD）**
- GitHub Actionsを採用
  - GitHubとシームレスに連携でき、pushをトリガーに自動デプロイを実現できるため  
  - 外部ツールを使わずシンプルな構成でCI/CDを構築できるため  

**構成管理**
- Ansibleを採用
  - サーバー構成をコード化し、手動作業による設定ミスを防止するため  
  - エージェントレスで導入コストが低く、Terraformとの組み合わせが容易であるため 

## 基本設計・ワークフロー
今回、Terraformの **modules機能** により、環境を*prod*と*stage*の２つ用意してます。
『pushされると、まず*stage*環境がデプロイ、アプリケーション起動まで問題なく動くことを確認し、メンバーの承認を得た後に*prod*環境がデプロイ、アプリケーションが起動する』構成にしています。
今回構成するワークフローは以下の通りです。

1\. `*.tf`ファイルや`.github/workflows/*.yaml`ファイルの変更をGitHubにプッシュ。

2\. GitHubのmainブランチにプルリクエストを送ると*stage*ディレクトリ内で自動で **terraform test** 実行。

3\. mainブランチにマージすることで自動で **terraform apply** を実行し*stage*環境構築。

4\. その後作成した*stage*環境のEC2に対しAnsibleを実行し、自動でアプリケーションをインストール。

5\. *stage*環境が正常に動作することを確認し、Github上で **environment** 操作を行うことで*prod*環境構築。

6\. 同様に作成した*prod*環境のEC2に対しAnsibleを実行し、自動でアプリケーションをインストール。

7\. ブラウザ上で `http://<EC2_IP>:8080`もしくは`http://< ALBのDNS名>`にアクセスし動作確認。

## インフラ構成図


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
- **名前:** `aws-study-prodigw`(prod),`aws-study-stageigw`(stage)

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
| `aws-study-**ec2sg` | EC2 |`aws-study-**albsg` -> `8080` (HTTP1)  |(デフォルト: ALL)|
| `aws-study-**dbsg` | RDS |`aws-study-**ec2sg` -> `3306` (TCP) |(デフォルト: ALL)|

**AWS WAF**
- **適用対象:** ALB
- **WebACL名:** `aws-study-prodalb-waf`(prod),`aws-study-stagealb-waf`(stage)
- **デフォルトアクション:** Block
- **ルール:**
    - **カスタムルール**
        - `IPAddressWhitelistRule`: 指定したIPアドレスからの通信を許可する。
- **ログ:** CloudWatch Logs Log Group(`aws-waf-logs-study-***alb`)に出力。

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
- **名前：** `aws-study-prod-topic`(prod),`aws-study-stage-topic`(stage)
- **通知先Email: GitHub Secretsで管理** 

**CloudWatch Logs・S3**
|  名称           | リソース名 |説明 |
| :------------------------------------- | :--: |:--: |
| `aws-waf-logs-study-***alb` | CloudWatch Logs |WAFログ保管用 |
| `aws-study-marube23-backet` | S3 |tfstateファイル保管用  |
| `aws-study-ansible-***-marube23-bucket` | S3 |Ansibleモジュール一時保管用 |

**IAM**
- **ポリシー:**
    - CloudWatch Logs にWAFログ収集に必要なリソースベースポリシーを付与。
- **ロール:**
    - GitHub OIDCを設定し、アクセスキーを使用しない。
    - EC2インスタンスにはSSM接続やS3アクセス権限を持つIAMロールをアタッチし、キーペアを使用しない。

**GitHub Secrets**
| 説明                             | 変数                    |
| :-------------------- | :----------------------: | 
| OIDC用IAMロールARN       | `"AWS_ROLE_ARN"`        | 
| DB ユーザー名           | `"DATABASE_MASTER_NAME"`          | 
| DB パスワード           | `"DB_PASSWORD"`          | 
| 通知用メールアドレス | `"MY_EMAIL"` | 
---

### 開発環境
| 項目 | 説明 |
| :-------------------- | :----------------------: | 
| インフラ構築(IaC) | Terraform 1.14.7 |
| 構成管理 | Ansible 2.16.6 |
| CI/CD | GitHub Actions |
| コード管理 | GitHub  |
| 使用端末 | MacBook Air 2017 |
| 開発環境 | VSCode / Git / Tarminal / AWS CLI |

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
├── envs/
│   ├── prod/
│   │   ├── main.tf                 # プロバイダー設定
│   │   ├── main.tftest.hcl         # テスト用ファイル
│   │   ├── outputs.tf              # 出力値定義
│   │   ├── terraform.tfvars        # サンプル変数ファイル
│   │   └── variables.tf            # 変数定義
│   └── stage/
│       ├── main.tf                 # プロバイダー設定
│       ├── main.tftest.hcl         # テスト用ファイル
│       ├── outputs.tf              # 出力値定義
│       ├── terraform.tfvars        # サンプル変数ファイル
│       └── variables.tf            # 変数定義
├── .gitignore
└── README.md
```
---

## GitHub Actions 概要（terraform.yaml）
- 以下の6つのジョブで構成。

| ジョブ名 | 内容 |
|-----------|------|
| **terraform-stage-plan** | プルリクエスト時、*stage*環境でTerraformの初期化、検証を実施(CI)。|
| **terraform-stage-apply** | マージされた時、*stage*環境でリソース構築を実施(CD)。構築後にEC2 ID・S3バケット名・RDS Endpointを出力 |
| **ansible-stage** | GitHub実行環境（ランナー）に ansible・boto3・botocore・SSMプラグインをインストール。動的inventoryを作成し、*stage*環境のEC2に Ansible Playbookを実行。 |
| **terraform-prod-plan** | *stage*環境構築後、*prod*環境でTerraformの初期化、検証を実施(CI)。|
| **terraform-prod-apply** | メンバー承認後、*prod*環境でリソース構築を実施(CD)。構築後にEC2 ID・S3バケット名・RDS Endpointを出力 |
| **ansible-stage** | Github実行環境（ランナー）に ansible・boto3・botocore・SSMプラグインをインストール。動的inventoryを作成し、*prod*環境のEC2に Ansible Playbookを実行。 |

---

## Ansible Playbook概要（playbook.yaml）
- 以下の4つのRoleで構成。

| Role名 | 実行内容 |
|---------------|-----------|
| **common** | Java 21 / Git をインストール |
| **mysql** | community.mysql をインストールし、MySQLクライアントを導入 |
| **app** | アプリケーションをCloneし、propertiesとDBに必要な値を入力 |
| **deploy** | アプリケーションをSystemd化し自動起動。HTTPチェックし動作確認 |

---

## 工夫した点

- **OIDC + SSMを用いた認証方式**
  - GitHub ActionsにはOpenID Connect (OIDC)、AnsibleにはSSM Session Manager接続を採用
  - アクセスキーやSSHキーペアを使用せず、22番ポートの開放も不要な構成とした
    - 認証情報の漏洩リスクを低減し、セキュアな運用を実現

- **modules化による環境分離**
  - Terraformのmodules機能を用い、開発・本番環境を同一コードで管理
  - GitHub Actionsに承認フローを組み込み、開発環境確認後に本番環境へ反映する構成とした
    - 環境差異による不具合を防ぎ、安全なリリースを実現

- **Systemdによるプロセス管理**
  - EC2上のアプリケーションをSystemdで管理
  - インスタンス起動時に自動起動するよう設定
    - 手動起動の手間を排除し、運用負荷の軽減と可用性向上に貢献

---

## 課題と解決
**① Terraformにおける依存関係の整理**
- **課題**  
  - modules化および複数環境構成により、variablesとoutputsの依存関係が複雑化し、terraform apply時にエラーが頻発
- **対応**  
  - terraform planをこまめに実行し、依存関係とエラー内容を都度整理  
  - outputsとvariablesの受け渡し構造を見直し
- **結果**  
  - 安定してapplyが通る構成を確立

**② GitHub Actions × SSM接続の実装**
- **課題**  
  - SSMを用いたAnsible接続の実装に関する情報が少なく、GitHub Actionsからの接続が確立できない状態が継続
- **対応**  
  - 実行ログをもとに必要なパラメータや設定値を一つずつ検証  
  - IAMロール・OIDC設定・SSM接続条件を切り分けて検証  
  - 検証を繰り返しながら構成を調整
- **結果**  
  - SSH不要で安全に接続可能な構成を実現  
  - 実装内容を技術記事としてZennにアウトプットし、再現性を確保  

**③ Ansible Playbook実行時のエラー対応**
- **課題**  
  - Playbook実行時にタスク失敗や想定外の挙動が多発し、安定した構成管理が困難
- **対応**  
  - debugタスクを追加し変数や処理内容を可視化  
  - HTTPリクエストチェックなど検証タスクを挿入し、処理の成否を段階的に確認  
  - エラー箇所を切り分けながら段階的に修正
- **結果**  
  - Playbookの安定実行を実現  
  - デバッグ手法を確立し、トラブルシュート能力を向上  

---

## 今後の改善点

- Blue/Greenデプロイを導入し、安全なリリースを実現する

- ACM + ALBによるHTTPS化を導入し、セキュリティ向上および実運用を意識した構成とする

- アプリケーションおよびRDSをログ集約し、運用上のパフォーマンス分析を容易にする

- SSMの操作履歴や実行ログを可視化し、運用監査およびトラブルシュートを強化する
