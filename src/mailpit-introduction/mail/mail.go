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

	fmt.Println("Email sent successfully!")
	return nil
}
