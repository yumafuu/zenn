import puppeteer from "https://deno.land/x/puppeteer@16.2.0/mod.ts";
import { WebClient } from "npm:@slack/web-api";

const main = async () => {
    const browserlessToken = Deno.env.get("BROWSERLESS_TOKEN");
    const slackToken = Deno.env.get("SLACK_TOKEN");
    if (!browserlessToken || !slackToken) {
        throw "[ERROR] `BROWSERLESS_TOKEN` and `SLACK_TOKEN` is required"
    }
    const browser = await puppeteer.connect({
      browserWSEndpoint: `wss://chrome.browserless.io?token=${browserlessToken}`,
    });

    const page = await browser.newPage();

    await page.goto('https://ispec.tech');
    await page.screenshot({ path: "/tmp/ispec.png" });

    await browser.close();

    const client = new WebClient(slackToken);
    await client.uploadV2({
        channel_id: "C01CUGE9E65",
        file: "/tmp/ispec.png",
        filename: "ispec.png",
    });
}

await main();
