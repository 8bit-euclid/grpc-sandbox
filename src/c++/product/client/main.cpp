#include <iostream>
#include <memory>
#include <string>
#include <format>
#include <iomanip>

#include <grpcpp/grpcpp.h>
#include "gen/c++/product/product_info.grpc.pb.h"
#include <google/protobuf/wrappers.pb.h>

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

    // Search products using streaming RPC
    void SearchProducts(const std::string& search_query) {
        // Prepare the request
        google::protobuf::StringValue request;
        request.set_value(search_query);

        // Context for the client
        grpc::ClientContext context;

        // Get the stream reader
        std::unique_ptr<grpc::ClientReader<product::Product>> reader(
            stub_->searchProducts(&context, request));

        // Read from the stream
        product::Product search_product;
        while (reader->Read(&search_product)) {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("Search Result -> ID: {}, Name: {}, Description: {}, Price: ${:.2f}\n",
                                   search_product.id(), search_product.name(),
                                   search_product.description(), search_product.price());
            #else
            std::cout << "Search Result -> ID: " << search_product.id()
                      << ", Name: " << search_product.name()
                      << ", Description: " << search_product.description()
                      << ", Price: $" << std::fixed << std::setprecision(2)
                      << search_product.price() << std::endl;
            #endif
        }

        // Check the final status
        grpc::Status status = reader->Finish();
        if (status.ok()) {
            std::cout << "EOF" << std::endl;
        } else {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("SearchProducts RPC failed: {} - {}\n",
                                   static_cast<int>(status.error_code()),
                                   status.error_message());
            #else
            std::cout << "SearchProducts RPC failed: " << status.error_code()
                      << " - " << status.error_message() << std::endl;
            #endif
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

        // Test data - matching Go implementation
        const std::string name1 = "Apple iPhone 11";
        const std::string description1 = "C++ client";
        const float price1 = 699.00f;

        const std::string name2 = "Google Pixel 4a";
        const std::string description2 = "C++ client";
        const float price2 = 399.00f;

        #if __cpp_lib_format >= 201907L
        std::cout << std::format("Connecting to server at {}\n", kServerAddress);
        #else
        std::cout << "Connecting to server at " << kServerAddress << std::endl;
        #endif

        // Add products
        std::string id1 = client.AddProduct(name1, description1, price1);
        std::string id2 = client.AddProduct(name2, description2, price2);

        if (!id1.empty()) {
            // Get the last product
            client.GetProduct(id1);
        }

        // Search Products
        std::cout << "\n--- Searching for 'Apple' ---" << std::endl;
        client.SearchProducts("Apple");

    } catch (const std::exception& e) {
        std::cerr << "Client failed with exception: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
