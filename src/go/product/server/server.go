// gRPC ProductInfo Server Implementation
// Code generation is handled by buf - run 'make generate' to regenerate protobuf files

package main

import (
	"context"
	"fmt"
	"log"
	"strings"

	pb "github.com/8bit-euclid/grpc-sandbox/gen/go/product"
	"github.com/gofrs/uuid"
	grpc "google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// server is used to implement ecommerce/product_info.
type server struct {
	pb.UnimplementedProductInfoServer  // Embed this to satisfy the interface
	productMap map[string]*pb.Product
}

// AddProduct implements ecommerce.AddProduct
func (s *server) AddProduct(ctx context.Context,
							in *pb.Product) (*pb.ProductID, error) {
	out, err := uuid.NewV4()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Error while generating Product ID: %v", err)
	}
	in.Id = out.String()
	if s.productMap == nil {
		s.productMap = make(map[string]*pb.Product)
	}
	s.productMap[in.Id] = in
	log.Printf("Product %v : %v - Added.", in.Id, in.Name)
	return &pb.ProductID{Value: in.Id}, status.New(codes.OK, "").Err()
}

// GetProduct implements ecommerce.GetProduct
func (s *server) GetProduct(ctx context.Context, in *pb.ProductID) (*pb.Product, error) {
	product, exists := s.productMap[in.Value]
	if exists && product != nil {
		log.Printf("Product %v : %v - Retrieved.", product.Id, product.Name)
		return product, status.New(codes.OK, "").Err()
	}
	return nil, status.Errorf(codes.NotFound, "Product with ID %s does not exist.", in.Value)
}

func (s *server) SearchProducts(searchQuery *wrapperspb.StringValue, stream grpc.ServerStreamingServer[pb.Product]) error {
	for key, product := range s.productMap {
		log.Print(key, product)
		itemStr := product.Name + " " + product.Description
		if strings.Contains(itemStr, searchQuery.Value) {
			// Send the matching products in a stream
			err := stream.Send(product)
			if err != nil {
				return fmt.Errorf("error sending message to stream : %v", err)
			}
			log.Print("Matching Product Found : " + key)
		}
	}
	return nil
}

func (s *server) UpdateProducts(stream grpc.ClientStreamingServer[pb.Product, wrapperspb.StringValue]) error {
	return nil
}