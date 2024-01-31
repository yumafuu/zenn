import $ from "https://deno.land/x/dax@0.38.0/mod.ts";

const options = [
  { ja: "吉村家", en: "yoshimuraya" },
  { ja: "杉田家", en: "sugitaya" },
  { ja: "たかさご家", en: "takasagoya" },
]

const index = await $.select({
  message: "What's your favourite shop?",
  options: options.map((o) => o.ja),
});

const selected = options[index]

let shop
const pb = $.progress("Fetching...");
await pb.with(async () => {
  const res = await fetch(`https://ramen-api.dev/shops/${selected.en}`)
  shop = (await res.json()).shop
});

const img = shop.photos[0].url
await $`curl -s ${img} -o ${selected.en}.jpg && wezterm imgcat ${selected.en}.jpg`
const result = await $.confirm({
  message: `${selected.ja}を食べ行きますか?`,
  default: true,
});

console.log(result);
