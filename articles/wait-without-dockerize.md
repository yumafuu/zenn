---
title: "docker composeでdockerizeやwait-for-itなしでmysqlの起動を待つ"
emoji: "🫸"
type: "tech"
topics: ["dockercompose"]
published: true
publication_name: "ispec_inc"
---

# モチベーション

[dockerize](https://github.com/jwilder/dockerize)や[wait-for-it](https://github.com/vishnubob/wait-for-it)を使わずにmysqlの起動を待ちたい

# depends_onとhealthcheckを使う

ドキュメントは以下の通り
[depends_on](https://docs.docker.com/compose/compose-file/compose-file-v3/#depends_on)
[healthcheck](https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck)

## 実際のファイル

```yaml:compose.yaml
services:
  server:
    container_name: awesome-server
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - '3000:3000'
    depends_on: # <- ここ
      awesome-mysql:
        condition: service_healthy

  mysql:
    container_name: awesome-mysql
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: hello
      MYSQL_ROOT_PASSWORD: password
    ports:
      - '3306:3306'
    healthcheck: # <- ここ
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

```

これでdockerizeやwait-for-itなしでmysqlの起動を待てるようになった！
