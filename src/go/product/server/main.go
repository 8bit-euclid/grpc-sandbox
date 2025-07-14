// gRPC ProductInfo Server
// Code generation is handled by buf - run 'make generate' to regenerate protobuf files
// Execute go run go/server/main.go

package main

import (
	"log"
	"net"

	pb "github.com/8bit-euclid/grpc-sandbox/gen/go/product"
	"google.golang.org/grpc"
)

const (
	port = ":50051"
)

func main() {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterProductInfoServer(s, &server{})
	
	log.Printf("Server is listening on %s", port)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}