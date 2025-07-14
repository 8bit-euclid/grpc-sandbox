#pragma once

#include <string>
#include <unordered_map>
#include <memory>
#include <random>
#include <format>

#include <grpcpp/grpcpp.h>
#include "product/product_info.grpc.pb.h"

namespace productinfo {

class ProductInfoServer final : public product::ProductInfo::Service {
public:
    ProductInfoServer();
    ~ProductInfoServer() override = default;

    // Implement the gRPC service methods
    grpc::Status addProduct(grpc::ServerContext* context,
                           const product::Product* request,
                           product::ProductID* response) override;

    grpc::Status getProduct(grpc::ServerContext* context,
                           const product::ProductID* request,
                           product::Product* response) override;

private:
    // Generate a UUID-like string for product IDs
    std::string generateProductId();

    // In-memory storage for products
    std::unordered_map<std::string, std::unique_ptr<product::Product>> product_map_;
    
    // Random number generator for UUID generation
    std::random_device rd_;
    std::mt19937 gen_;
    std::uniform_int_distribution<> dis_;
};

} // namespace productinfo
