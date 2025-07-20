#include <iostream>
#include <memory>
#include <string>
#include <format>
#include <iomanip>

#include <grpcpp/grpcpp.h>
#include "gen/c++/product/product_info.grpc.pb.h"

namespace {
    constexpr const char* kServerAddress = "localhost:50051";
}

class ProductInfoClient {
public:
    ProductInfoClient(std::shared_ptr<grpc::Channel> channel)
        : stub_(product::ProductInfo::NewStub(channel)) {}

    // Add a product and return the product ID
    std::string AddProduct(const std::string& name, 
                          const std::string& description, 
                          float price) {
        // Prepare the request
        product::Product request;
        request.set_name(name);
        request.set_description(description);
        request.set_price(price);

        // Container for the data we expect from the server
        product::ProductID reply;

        // Context for the client
        grpc::ClientContext context;

        // The actual RPC
        grpc::Status status = stub_->addProduct(&context, request, &reply);

        // Act upon its status
        if (status.ok()) {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("Product added with ID: {}\n", reply.value());
            #else
            std::cout << "Product added with ID: " << reply.value() << std::endl;
            #endif
            return reply.value();
        } else {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("RPC failed: {} - {}\n", 
                                   static_cast<int>(status.error_code()), 
                                   status.error_message());
            #else
            std::cout << "RPC failed: " << status.error_code() 
                      << " - " << status.error_message() << std::endl;
            #endif
            return "";
        }
    }

    // Get a product by ID
    bool GetProduct(const std::string& product_id) {
        // Prepare the request
        product::ProductID request;
        request.set_value(product_id);

        // Container for the data we expect from the server
        product::Product reply;

        // Context for the client
        grpc::ClientContext context;

        // The actual RPC
        grpc::Status status = stub_->getProduct(&context, request, &reply);

        // Act upon its status
        if (status.ok()) {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("Product retrieved:\n");
            std::cout << std::format("  ID: {}\n", reply.id());
            std::cout << std::format("  Name: {}\n", reply.name());
            std::cout << std::format("  Description: {}\n", reply.description());
            std::cout << std::format("  Price: ${:.2f}\n", reply.price());
            #else
            std::cout << "Product retrieved:" << std::endl;
            std::cout << "  ID: " << reply.id() << std::endl;
            std::cout << "  Name: " << reply.name() << std::endl;
            std::cout << "  Description: " << reply.description() << std::endl;
            std::cout << "  Price: $" << std::fixed << std::setprecision(2) 
                      << reply.price() << std::endl;
            #endif
            return true;
        } else {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("RPC failed: {} - {}\n", 
                                   static_cast<int>(status.error_code()), 
                                   status.error_message());
            #else
            std::cout << "RPC failed: " << status.error_code() 
                      << " - " << status.error_message() << std::endl;
            #endif
            return false;
        }
    }

private:
    std::unique_ptr<product::ProductInfo::Stub> stub_;
};

int main(int argc, char** argv) {
    try {
        // Create a channel to the server
        auto channel = grpc::CreateChannel(kServerAddress, grpc::InsecureChannelCredentials());
        
        // Create the client
        ProductInfoClient client(channel);

        // Test data
        const std::string name = "Apple iPhone 15";
        const std::string description = "Latest iPhone with advanced features and improved performance.";
        const float price = 999.99f;

        #if __cpp_lib_format >= 201907L
        std::cout << std::format("Connecting to server at {}\n", kServerAddress);
        #else
        std::cout << "Connecting to server at " << kServerAddress << std::endl;
        #endif

        // Add a product
        std::string product_id = client.AddProduct(name, description, price);
        
        if (!product_id.empty()) {
            // Retrieve the product
            client.GetProduct(product_id);
        }

    } catch (const std::exception& e) {
        std::cerr << "Client failed with exception: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
