package helloworld

import (
	"fmt"
	"net/http"
	"sync"
)

type HelloWorld struct {
	sync.Mutex
	count int
}

func (h *HelloWorld) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var count int
	h.Lock()
	h.count++
	count = h.count
	h.Unlock()
	fmt.Fprintf(w, "Hello, world! You have called me %d times.\n", count)
}
