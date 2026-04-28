package main

import (
	"os"
	"syscall"

	"github.com/jeeftor/audiobook-organizer/cmd"
)

func main() {
	// Ensure created directories get full 0777 permissions regardless of
	// the process umask (which may be 022 in docker exec sessions).
	syscall.Umask(0)

	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
