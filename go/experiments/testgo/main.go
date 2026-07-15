package main

/*testing compilation for Linux*/
import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("Go Code Running on %s.%s\n", runtime.GOOS, runtime.GOARCH)
}
