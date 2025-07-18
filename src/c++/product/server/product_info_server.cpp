#include "product_info_server.h"
#include <iostream>
#include <sstream>
#include <iomanip>

namespace productinfo {

ProductInfoServer::ProductInfoServer() 
    : gen_(rd_()), dis_(0, 15) {
}

std::string ProductInfoServer::generateProductId() {
    // Generate a simple UUID-like string using C++23 features
    std::stringstream ss;
    ss << std::hex;

    // Generate 8-4-4-4-12 format like UUID
    for (int i = 0; i < 8; ++i) ss << dis_(gen_);
    ss << "-";
    for (int i = 0; i < 4; ++i) ss << dis_(gen_);
    ss << "-";
    for (int i = 0; i < 4; ++i) ss << dis_(gen_);
    ss << "-";
    for (int i = 0; i < 4; ++i) ss << dis_(gen_);
    ss << "-";
    for (int i = 0; i < 12; ++i) ss << dis_(gen_);

    return ss.str();
}

grpc::Status ProductInfoServer::addProduct(grpc::ServerContext* context,
                                          const product::Product* request,
                                          product::ProductID* response) {
    try {
        // Generate a new product ID
        std::string product_id = generateProductId();
        
        // Create a new product with the generated ID
        auto new_product = std::make_unique<product::Product>(*request);
        new_product->set_id(product_id);
        
        // Store the product in our map
        product_map_[product_id] = std::move(new_product);
        
        // Set the response
        response->set_value(product_id);
        
        // Log the addition
        std::cout << "Product " << product_id << " : " << request->name()
                  << " - Added." << std::endl;
        
        return grpc::Status::OK;
    } catch (const std::exception& e) {
        return grpc::Status(grpc::StatusCode::INTERNAL, 
                           "Error while generating Product ID: " + std::string(e.what()));
    }
}

grpc::Status ProductInfoServer::getProduct(grpc::ServerContext* context,
                                          const product::ProductID* request,
                                          product::Product* response) {
    const std::string& product_id = request->value();
    
    // Look for the product in our map
    auto it = product_map_.find(product_id);
    if (it != product_map_.end() && it->second) {
        // Product found, copy it to the response
        *response = *(it->second);
        
        // Log the retrieval using C++23 std::format (if available) or fallback
        #if __cpp_lib_format >= 201907L
        std::cout << std::format("Product {} : {} - Retrieved.\n", 
                                response->id(), response->name());
        #else
        std::cout << "Product " << response->id() << " : " << response->name() 
                  << " - Retrieved." << std::endl;
        #endif
        
        return grpc::Status::OK;
    }
    
    // Product not found
    return grpc::Status(grpc::StatusCode::NOT_FOUND, 
                       "Product with ID " + product_id + " does not exist.");
}

} // namespace productinfo
