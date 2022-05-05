package main

import (
	"fmt"
	"log"
	"net/http"
)

func HelloHandler(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "hello\n")
}

func main() {
	http.HandleFunc("/", HelloHandler)
	log.Println("Listening...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
