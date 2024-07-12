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
