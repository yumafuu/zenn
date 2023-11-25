---
title: "Denoとbrowserlessで最速でスクレイピングしてみる"
emoji: "🧑🏼‍💻"
type: "tech"
topics: ["deno", "puppeteer", "browserless"]
published: false
publication_name: "ispec_inc"
---

# スクレイピングはめんどくさい

以前にこんな記事を書きましたが、
https://zenn.dev/ispec_inc/articles/lambda-puppeteer

手順が多すぎて諦めたくなります、、、
サーバーでブラウザを操作したいだけなのに！！

# Deno + browserless

ここで browserless という

https://www.browserless.io/

```js
import puppeteer from "https://deno.land/x/puppeteer@16.2.0/mod.ts";

const browser = await puppeteer.connect({
  browserWSEndpoint: `wss://chrome.browserless.io?token=${Deno.env.get("BROWSERLESS_TOKEN")}`,
});

const page = await browser.newPage();

await page.goto('https://ispec.tech');
await page.screenshot({ path: "/tmp/ispec.png" });

await browser.close();

```

```bash
$ deno run -A index.js
```
