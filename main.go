package main

import (
	"github.com/joshmyers/helloworld/helloworld"
	"log"
	"net/http"
)

const (
	PORT = ":8080"
)

func main() {
	mux := http.NewServeMux()
	handler := &helloworld.HelloWorld{}
	mux.Handle("/favicon.ico", http.NotFoundHandler())
	mux.Handle("/", handler)
	log.Printf("Started a server at localhost%s...\n", PORT)
	server := http.Server{Handler: mux, Addr: PORT}
	log.Fatal(server.ListenAndServe())
}
