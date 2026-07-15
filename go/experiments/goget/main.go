package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

const (
	downloadURL  = "https://miphack.com/zxl8"
	outputFile   = "zxl8.download"
	expectedHash = "REPLACE_WITH_EXPECTED_SHA256"
)

func main() {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	resp, err := client.Get(downloadURL)
	if err != nil {
		exitError("download failed", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		exitError(
			"unexpected HTTP response",
			fmt.Errorf("%s", resp.Status),
		)
	}

	tempFile := outputFile + ".tmp"

	file, err := os.OpenFile(
		tempFile,
		os.O_CREATE|os.O_WRONLY|os.O_TRUNC,
		0600,
	)
	if err != nil {
		exitError("could not create output file", err)
	}

	hasher := sha256.New()
	writer := io.MultiWriter(file, hasher)

	if _, err := io.Copy(writer, resp.Body); err != nil {
		file.Close()
		os.Remove(tempFile)
		exitError("could not save download", err)
	}

	if err := file.Close(); err != nil {
		os.Remove(tempFile)
		exitError("could not close output file", err)
	}

	actualHash := hex.EncodeToString(hasher.Sum(nil))

	if !strings.EqualFold(actualHash, expectedHash) {
		os.Remove(tempFile)
		exitError(
			"SHA-256 verification failed",
			fmt.Errorf("expected %s, received %s", expectedHash, actualHash),
		)
	}

	if err := os.Rename(tempFile, outputFile); err != nil {
		os.Remove(tempFile)
		exitError("could not finalize output file", err)
	}

	fmt.Printf("Downloaded and verified: %s\n", outputFile)
	fmt.Printf("SHA-256: %s\n", actualHash)
	fmt.Println("Review the file before executing it manually.")
}

func exitError(message string, err error) {
	fmt.Fprintf(os.Stderr, "%s: %v\n", message, err)
	os.Exit(1)
}