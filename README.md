# Introduction
このレポジトリーは社内専用となります。取引先や外部関係者のために公開しています。  
個別のお問い合わせやご要望にはお応えできかねますことをご了承下さい。

# Installation
## 自動インストール
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/timoshka-lab/docker-dev-wordpress-setup/main/setup.sh)"
```

## 手動インストール
```zsh
cd [WORKING_DIR]
curl -L https://github.com/timoshka-lab/docker-dev-wordpress/archive/main.tar.gz | tar xvz -C ./ --strip-components=1
cp .env.example .env

# .envを編集

docker compose build
docker compose up -d
docker compose exec app /setup.sh [--version version] [--skip-wp]

# 1. 'setup.sh'の出力内でWordPressのパスワードを確認します。
# 2. '/etc/hosts' ファイルを編集します。詳細はこちら：'docker compose logs web'
# 3. 'docker/nginx/certs' 内の 'server.crt' 証明書をキーチェーンに追加します。
# 4. "$WP_SITE_URL" で設定したURLをブラウザで確認できます。
# 5. 'Dev SMTP' プラグインを管理画面から有効化します。 Mailhogへのアクセスこちら：http://127.0.0.1:8025/.
# 6. プロジェクトの管理方法に応じて '.gitignore' ファイルを編集して下さい。
```

# Usage
```zsh
cd [WORKING_DIR]
docker compose up -d

# Do something...

docker compose down
```

# Notices
このプロジェクトは本番環境を想定していません。  
本番環境やステージング環境での利用は避けて下さい。  
目的外の利用による損害については一切の責任を負いません。

THIS PROJECT IS NOT INTENDED FOR PRODUCTION USE.  
DO NOT USE IT IN PRODUCTION OR STAGING ENVIRONMENT.  
IT IS ONLY FOR LOCAL DEVELOPMENT PURPOSES.

# Staging Deployment
ステージング環境専用に構築されたレポジトリー（非公開）はこちらになります。  
[https://github.com/timoshka-lab/dev-vms-wordpress](https://github.com/timoshka-lab/dev-vms-wordpress)