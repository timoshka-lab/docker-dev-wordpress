# Introduction
このレポジトリーは社内専用となります。取引先や外部関係者のために公開しています。  
個別のお問い合わせやご要望にはお応えできかねますことをご了承下さい。

# 新規プロジェクトの開始
## 自動インストール
```bash
cd [WORKING_DIR]
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/timoshka-lab/docker-dev-wordpress-setup/main/setup.sh)"
```

### インストール後の設定・確認
* '/etc/hosts' ファイルを編集します。詳細はこちら： 'docker compose logs web'
* '$WP_SITE_URL' で設定したURLをブラウザで確認できます。
* WordPressの管理ユーザーパスワードは 'develop' です。
* 'Dev SMTP' プラグインを管理画面から有効化します。 Mailhogへのアクセスこちら： [http://127.0.0.1:8025/](http://127.0.0.1:8025/).
* プロジェクトの管理方法に応じて '.gitignore' ファイルを編集して下さい。

## 手動インストール
```zsh
cd [WORKING_DIR]
curl -L https://github.com/timoshka-lab/docker-dev-wordpress/archive/main.tar.gz | tar xvz -C ./ --strip-components=1
cp .env.example .env
cp .env.wp-salt.example .env.wp-salt

# .envと.env.wp-saltファイルを編集

docker compose build
docker network inspect wordpress-shared > /dev/null 2>&1 || docker network create wordpress-shared
docker compose up -d
docker compose exec app /setup.sh [--version version] [--skip-wp]
```

### インストール後の設定・確認
* '/etc/hosts' ファイルを編集します。詳細はこちら： 'docker compose logs web'
* 'docker/storage/nginx/certs' 内の 'server.crt' 証明書を端末のキーチェーンに追加します。
* '$WP_SITE_URL' で設定したURLをブラウザで確認できます。
* WordPressの管理ユーザーパスワードは 'develop' です。
* 'Dev SMTP' プラグインを管理画面から有効化します。 Mailhogへのアクセスこちら： [http://127.0.0.1:8025/](http://127.0.0.1:8025/).
* プロジェクトの管理方法に応じて '.gitignore' ファイルを編集して下さい。

# 使い方
## 一般的なユースケース
```zsh
cd [WORKING_DIR]
docker compose up -d

# 開発作業...

docker compose down
```

## データベースのエクスポート
```zsh
# docker/storage/app/initdb.d/001-mysql-init.sql にエクスポートされます。
docker compose exec app /export.sh
```

## データベースのインポート
```zsh
# docker/storage/app/initdb.d/001-mysql-init.sql からインポートされます。
docker compose exec app /import.sh
```

# 既存プロジェクトの共有
## 共有する側の準備
```zsh
# データベースファイルをエクスポートし、pushします。
docker compose exec app /export.sh [--pass password] [--skip-pass-reset]
```

## 共有される側の準備
### 1. プロジェクトレポジトリーの設置
```zsh
cd [WORKING_DIR]
git clone [REPO_URL]
cd [REPO_NAME]
```

### 2.1 自動インストール
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/timoshka-lab/docker-dev-wordpress-setup/main/setup.sh)"
```

#### インストール後の設定・確認
* '/etc/hosts' ファイルを編集します。詳細はこちら： 'docker compose logs web'
* '$WP_SITE_URL' で設定したURLをブラウザで確認できます。
* WordPressの管理ユーザーパスワードは 'develop' です。
* 'Dev SMTP' プラグインを管理画面から有効化します。 Mailhogへのアクセスこちら： [http://127.0.0.1:8025/](http://127.0.0.1:8025/).

### 2.2 手動インストール
```zsh
# ENVファイルをテンプレートからコピーします。ENVファイルをGitで管理している場合は不要です。
cp .env.example .env
cp .env.wp-salt.example .env.wp-salt
# .envと.env.wp-saltファイルを編集

docker compose build
docker network inspect wordpress-shared > /dev/null 2>&1 || docker network create wordpress-shared
docker compose up -d
docker compose exec app /setup.sh [--version version]
```

#### インストール後の設定・確認
* '/etc/hosts' ファイルを編集します。詳細はこちら： 'docker compose logs web'
* 'docker/storage/nginx/certs' 内の 'server.crt' 証明書を端末のキーチェーンに追加します。
* '$WP_SITE_URL' で設定したURLをブラウザで確認できます。
* WordPressの管理ユーザーパスワードは 'develop' です。
* 'Dev SMTP' プラグインを管理画面から有効化します。 Mailhogへのアクセスこちら： [http://127.0.0.1:8025/](http://127.0.0.1:8025/).


# プロジェクトの管理について
このレポジトリーはWordPressの開発環境を構築するためのスターターキットになります。  
このスターターキットを使って作成されたプロジェクトは、Gitで管理されることを想定しています。  

Gitで管理を行う場合には、レポジトリーを必ず「非公開設定」で管理して下さい。  
また、開発環境の構築を目的としているため、ネットワークの外部からアクセスできない端末でご利用下さい。
本番環境をDockerコンテナで構築する場合は、本レポジトリーと混合しないようにして下さい。  

スターターキットは、SQLファイルの自動エクスポートを行っていますため、  
Gitで管理する場合は、機密情報が含まれる可能性がありますことをご理解の上で管理を行って下さい。

# Notices
このプロジェクトは本番環境を想定していません。  
本番環境やステージング環境での利用は避けて下さい。  
目的外の利用による損害については一切の責任を負いません。

THIS PROJECT IS NOT INTENDED FOR PRODUCTION USE.  
DO NOT USE IT IN PRODUCTION OR STAGING ENVIRONMENT.  
IT IS ONLY FOR LOCAL DEVELOPMENT PURPOSES.
