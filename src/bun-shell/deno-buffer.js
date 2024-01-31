import $ from "https://deno.land/x/dax@0.38.0/mod.ts";


const response = new Response("hello i am a response body");
const result = await $`cat < ${response}`.text();

console.log(result);
