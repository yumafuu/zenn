---
title: "metabaseをfargateにデプロイする時はenable_dns_hostnamesをtrueにして"
emoji: "🦭"
type: "tech"
topics: ["aws", "fargate", "metabase"]
published: true
publication_name: "ispec_inc"
---

# 起きたこと

[Metabase](https://www.metabase.com/)をFargateに乗せて公開しようと思ったら、migrationは通るけど

```bash

# こんなエラーとか
08-21 13:34:30 ERROR impl.StdSchedulerFactory :: Couldn't generate instance Id!
org.quartz.SchedulerException: Couldn't get host name! [See nested exception: java.net.UnknownHostException: 00bcf2fe65d4: 00bcf2fe65d4: Name does not resolve]

# こんなエラーとか
08-21 13:34:30 ERROR metabase.core :: Metabase Initialization FAILED
java.lang.IllegalStateException: Cannot run without an instance id.

# 色々エラー吐いて落ちる
08-21 13:34:30 INFO metabase.core :: Metabase Shutting Down ...
08-21 13:34:30 INFO metabase.core :: Metabase Shutdown COMPLETE
```

という現象が発生した

# 解決策

[Problems with DNS on AWS Fargate · Issue #8373 · metabase/metabase](https://github.com/metabase/metabase/issues/8373)

こちらに書いてあります

https://github.com/metabase/metabase/issues/8373#issuecomment-728948066

metabase初期化にHost名を取得する処理が入ってるっぽくて、VPCの`enable_dns_hostnames`っていうオプションを`true`にしないといけないらしいです

これで動いた

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  # ...
  enable_dns_hostnames   = true
}
```
