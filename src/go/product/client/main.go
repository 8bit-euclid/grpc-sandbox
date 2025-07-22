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
	stub := pb.NewProductInfoClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	
	// Add Product 1
	name := "Apple iPhone 11"
	description := "Go client"
	price := float32(699.00)
	r, err := stub.AddProduct(ctx, &pb.Product{Name: name, Description: description, Price: price})
	if err != nil {
		log.Fatalf("Could not add product: %v", err)
	}
	log.Print("AddProduct Response -> ", r.Value)

	// Add Product 2
	name = "Google Pixel 4a"
	description = "Go client"
	price = float32(399.00)
	r, err = stub.AddProduct(ctx, &pb.Product{Name: name, Description: description, Price: price})
	if err != nil {
		log.Fatalf("Could not add product: %v", err)
	}
	log.Print("AddProduct Response -> ", r.Value)

	// =========================================
	// Get Product: Unary RPC
	product, err := stub.GetProduct(ctx, &pb.ProductID{Value: r.Value})
	if err != nil {
		log.Fatalf("Could not get product: %v", err)
	}
	log.Print("GetProduct Response -> ", product)

	// =========================================
	// Search products: Server streaming 
	searchStream, 	_ := stub.SearchProducts(ctx, &wrapperspb.StringValue{Value: "Apple"})
	for {
		searchProduct, err := searchStream.Recv()
		if err == io.EOF {
			break
		}

		if err == nil {
			log.Print("Search Result -> ", searchProduct)
		}
	}

	// =========================================
	// Update products: Client streaming 
	updProd1 := pb.Product{Id: "101", Name: "Samsung Galaxy S20", Description: "Go client", Price: 799.00}
	updProd2 := pb.Product{Id: "103", Name: "Apple Watch S4", Description: "Go client", Price: 399.00}

	updateStream, err := stub.UpdateProducts(ctx)

	if err != nil {
		log.Fatalf("%v.UpdateOrders(_) = _, %v", stub, err)
	}

	// Updating order 1
	if err := updateStream.Send(&updProd1); err != nil {
		log.Fatalf("%v.Send(%v) = %v", updateStream, updProd1, err)
	}

	// Updating order 2
	if err := updateStream.Send(&updProd2); err != nil {
		log.Fatalf("%v.Send(%v) = %v", updateStream, updProd2, err)
	}

	updateRes, err := updateStream.CloseAndRecv()
	if err != nil {
		log.Fatalf("%v.CloseAndRecv() got error %v, want %v", updateStream, err, nil)
	}
	log.Printf("Update Result -> %s", updateRes)

	// =========================================
	// Process products: Bi-directional streaming 
}