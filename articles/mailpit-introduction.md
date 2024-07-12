---
title: mailpitでメール送信のテストをする with Go
emoji: 💌
type: tech
topics: [mailpit, go, aquaclivm]
published: true
publication_name: ispec_inc
---

# はじめに

mailpitは、SMTPを使ったメール送信のテストを行うためのツールです。

MFAなどでシステムからメールを送る場面は多いと思います。

本番環境ではAWS SESなどメールサーバーを用意すると思いますが、ローカルでの開発やテスト環境ではメールサーバーを用意するのは大変ですよね。。

Mailpit は実際にメールを送信することなく、送信したメールを保存し、その内容を API や Web UI から確認することができます。

この記事では、mailpitを使ってメール送信のテストを行う方法について解説します！

- [Mailpit - email & SMTP testing tool](https://mailpit.axllent.org/)

(スターが4.9kもあるのに日本語の記事が全然なかった)

# 実装

## インストール

go製でワンバイナリで動くので、インストールも簡単です！


```bash
# brewでinstallできます
$ brew install mailpit

# aquaでも入ります
$ aqua g -i axllent/mailpit
```

余談ですが、aquaになかったので、PRをおくったら秒でマージしてリリースしてくれました！
https://github.com/aquaproj/aqua-registry/pull/24827

Thank you @suzuki-shunsukeさま !

## 使い方

設定なしで起動して使うことができます。
```bash
$ mailpit
```

http://localhost:8025 にアクセスすると、メールの一覧が表示されます。
[![Image from Gyazo](https://i.gyazo.com/b3987079414db27890e308bd449dac07.png)](https://gyazo.com/b3987079414db27890e308bd449dac07)

当たり前ですがまだメールを送信してないので、何も表示されていません。

cliにsendmailというサブコマンドがあり、メール標準入力でメールを渡すとmailpitにメールが保存されます。

もちろんSMTPでメールを送信することもできます。後ほどGoで実装してみます。

```bash
$ echo -e "To: to@example.com\r\nFrom: from@example.com\r\nSubject: Test Email\n\nThis is a test email."  | \
    mailpit sendmail
```

すると、、
[![Image from Gyazo](https://i.gyazo.com/cc9a9997f68f0ec92a94abdd96adfa5e.png)](https://gyazo.com/cc9a9997f68f0ec92a94abdd96adfa5e)

[![Image from Gyazo](https://i.gyazo.com/4d006b5b707ab7c9249ba99d0327c711.png)](https://gyazo.com/4d006b5b707ab7c9249ba99d0327c711)

こんな感じでメールが保存されているのが確認できます！

UIも使いやすいです。

Apiでも送信したメールが確認できるので、やってみます。

```bash
# 本文だけ確認する
$ curl http://localhost:8025/view/latest.txt
This is a test email.

# サマリーを確認
$ curl -s http://localhost:8025/api/v1/message/latest | jq
{
  "ID": "B9q5RcacW9wdQP6MRSCmBg",
  "MessageID": "Rp8CrKXnraG5678Q8TjwWT@mailpit",
  "From": {
    "Name": "",
    "Address": "from@example.com"
  },
  "To": [
    {
      "Name": "",
      "Address": "to@example.com"
    }
  ],
  "Cc": [],
  "Bcc": [],
  "ReplyTo": [],
  "ReturnPath": "yuma@yuma-pc",
  "Subject": "Test Email",
  "ListUnsubscribe": {
    "Header": "",
    "Links": [],
    "Errors": "",
    "HeaderPost": ""
  },
  "Date": "2024-07-12T18:32:28.308+09:00",
  "Tags": [],
  "Text": "This is a test email.\r\n",
  "HTML": "",
  "Size": 318,
  "Inline": [],
  "Attachments": []
}

```

👇他にも色々Apiがあるので確認してみてください
- [API (v1) - Mailpit](https://mailpit.axllent.org/docs/api-v1/)

## Goでの実装例

Goでメールを送信して正しく送信されたか確認するためのテストを書いてみます。

雑にmailパッケージを作って、Send関数を作ります。
```go
package mail

import (
	"fmt"
	"net/smtp"
)

func Send(to, from, body string) error {
	msg := fmt.Sprintf(
		"To: %s\r\nFrom: %s\r\nSubject: Test Email\n\n%s",
		to,
		from,
		body,
	)

	addr := "localhost:1025"
	err := smtp.SendMail(addr, nil, from, []string{to}, []byte(msg))
	if err != nil {
		return err
	}

	return nil
}

```

そしたらこんな感じでテストが書けます！
```go
package mail_test

import (
	"io"
	"net/http"
	"testing"

	"mailpit-test/mail"

	"github.com/stretchr/testify/assert"
)

func Test_Main(t *testing.T) {
	t.Run("メール本文が正しいことを確認", func(t *testing.T) {
		to := "to@example"
		from := "from@example.com"
		body := "This is a test email.\r\n"
		err := mail.Send(to, from, body)
		if err != nil {
			t.Fatalf("エラーが発生しました: %v", err)
		}

		actual, err := getLatestMailFromMailpit()
		if err != nil {
			t.Fatalf("エラーが発生しました: %v", err)
		}
		assert.Equal(t, body, actual, "Should be the same.")
	})
}

func getLatestMailFromMailpit() (string, error) {
	resp, err := http.Get("http://localhost:8025/view/latest.txt")
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(b), nil
}

```

ちゃんとテストが通ることを確認できます！
```bash
$ go test ./mail -v
=== RUN   Test_Main
=== RUN   Test_Main/メール本文が正しいことを確認
--- PASS: Test_Main (0.00s)
    --- PASS: Test_Main/メール本文が正しいことを確認 (0.00s)
PASS
ok      mailpit-test/mail       0.005s
```

# おわりに

mailpitを使うことで、ローカルでの開発やテスト環境でのメール送信のテストが簡単に行えるようになります！

ぜひメールの送信テストに使ってみてください！
