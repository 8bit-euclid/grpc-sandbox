// gRPC ProductInfo Client
// Code generation is handled by buf - run 'make generate' to regenerate protobuf files
// Execute go run go/client/main.go

package main

import (
	"context"
	"io"
	"log"
	"time"

	pb "github.com/8bit-euclid/grpc-sandbox/gen/go/product"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

const (
	address = "localhost:50051"
)

func main() {
	// Set up a connection to the server.
	conn, err := grpc.NewClient(address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewProductInfoClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	
	// Add Product 1
	name := "Apple iPhone 11"
	description := "Go client"
	price := float32(699.00)
	r, err := c.AddProduct(ctx, &pb.Product{Name: name, Description: description, Price: price})
	if err != nil {
		log.Fatalf("Could not add product: %v", err)
	}
	log.Print("AddProduct Response -> ", r.Value)

	// Add Product 2
	name = "Google Pixel 4a"
	description = "Go client"
	price = float32(399.00)
	r, err = c.AddProduct(ctx, &pb.Product{Name: name, Description: description, Price: price})
	if err != nil {
		log.Fatalf("Could not add product: %v", err)
	}
	log.Print("AddProduct Response -> ", r.Value)

	// Get Product
	product, err := c.GetProduct(ctx, &pb.ProductID{Value: r.Value})
	if err != nil {
		log.Fatalf("Could not get product: %v", err)
	}
	log.Print("GetProduct Response -> ", product)

	// Search Products
	searchStream, 	_ := c.SearchProducts(ctx, &wrapperspb.StringValue{Value: "Apple"})
	for {
		searchProduct, err := searchStream.Recv()
		if err == io.EOF {
			log.Print("EOF")
			break
		}

		if err == nil {
			log.Print("Search Result -> ", searchProduct)
		}
	}
}