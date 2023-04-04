---
title: "Lambdaでpuppeteerを動かす"
emoji: "💨"
type: "tech"
topics: ["aws", "lambda", "puppeteer", "lambroll"]
published: false
---

# 概要

lambdaでpuppeteerを動かしたかったけど情報がまとまってなかったのでまとめる


## 環境

Lambda(nodejs18.x)


## 使うもの

- [puppeteer-core](https://github.com/puppeteer/puppeteer/tree/main#puppeteer-core)

puppeteerをインストールするとchromiumとpuppeteer-coreがinstallされるけど、chromiumは後述の@sparticuz/chromiumで使えるようになるのでpuppeteer-coreだけ入れる

- [@sparticuz/chromium](https://github.com/Sparticuz/chromium)

[alixaxel/chrome-aws-lambda](https://github.com/alixaxel/chrome-aws-lambda)の後継で、chromiumをlambdaで使えるようにするもの


# 手順

chromiumと日本語フォント用のlayerを作成します

1. zipサイズが50MBを超えるためデプロイ用のS3バケットを作っておく (`some-bucket`とする)

2. @sparticuz/chromiumをビルドしてzipで固めてlayerとして登録する

```bash
$ git clone --depth=1 https://github.com/sparticuz/chromium.git && \
  cd chromium && \
  make chromium.zip && \
  bucketName="some-bucket" && \
  versionNumber="107" && \
  aws s3 cp chromium.zip "s3://${bucketName}/chromiumLayers/chromium${versionNumber}.zip" && \
  aws lambda publish-layer-version \
    --layer-name chromium \
    --description "Chromium v${versionNumber}" \
    --content "S3Bucket=${bucketName},S3Key=chromiumLayers/chromium${versionNumber}.zip" \
    --compatible-runtimes nodejs \
    --compatible-architectures x86_64
```

3. 日本語フォントをzipで固めてlayerとして登録する
```bash
$ mkdir fonts && \
  cd fonts && \
  curl -O https://moji.or.jp/wp-content/ipafont/IPAexfont/IPAexfont00401.zip && \
  unzip IPAexfont00401.zip && \
  mkdir .fonts && \
  cp IPAexfont00401/*.ttf .fonts/ && \
  zip -r fonts .fonts && \
  aws lambda publish-layer-version \
    --layer-name japanese-fonts \
    --description "japanese-fonts" \
    --zip-file fileb://fonts.zip \
    --compatible-runtimes nodejs \
    --compatible-architectures x86_64
```

4. さっきつくったレイヤーを登録する

こんな感じ

[![Image from Gyazo](https://i.gyazo.com/1ebe3a5a7ee85488af29fd6c35e3c7c7.png)](https://gyazo.com/1ebe3a5a7ee85488af29fd6c35e3c7c7)

5. lambda関数をデプロイする

```js
# index.js
const puppeteer = require("puppeteer-core");
const chromium = require("@sparticuz/chromium");

exports.handler = async (event, context) => {
  const browser = await puppeteer.launch({
    args: chromium.args,
    defaultViewport: chromium.defaultViewport,
    executablePath: await chromium.executablePath(),
    headless: chromium.headless,
    ignoreHTTPSErrors: true,
  });

  const page = await browser.newPage();

  const dest = "/tmp/screenshot.png"

  await page.goto('https://example.com');
  await page.screenshot({ path: "/tmp/screenshot.png" });
  await browser.close();

  return "ok"
}

```


これで動くはず
