---
title: "最速でスクレイピングする方法"
emoji: "🧑🏼‍💻"
type: "tech"
topics: ["deno", "puppeteer", "browserless"]
published: false
publication_name: "ispec_inc"
---

# スクレイピングはめんどくさい

スクレイピングしようとするとChromeDriverのinstallとか色々やらないといけないことが多くて、めんどくさいです。

# Deno + browserless

ここで

https://www.browserless.io/

```js
import puppeteer from "https://deno.land/x/puppeteer@16.2.0/mod.ts";

const browser = await puppeteer.connect({
  browserWSEndpoint: `wss://chrome.browserless.io?token=${Deno.env.get("BROWSERLESS_TOKEN")}`,
});

const page = await browser.newPage();

const path = "/tmp/screenshot.png"

await page.goto('https://example.com');
await page.screenshot({ path });

await browser.close();

```

```bash
$ deno run -A index.js
```
