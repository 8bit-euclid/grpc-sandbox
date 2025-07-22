#include <iostream>
#include <memory>
#include <string>
#include <format>
#include <iomanip>
#include <vector>

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
        std::unique_ptr<grpc::ClientReader<product::Product>> stream(
            stub_->searchProducts(&context, request));

        // Read from the stream
        product::Product search_product;
        while (stream->Read(&search_product)) {
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
        grpc::Status status = stream->Finish();
        if (!status.ok()) {
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

    // Update products using client streaming RPC
    void UpdateProducts(const std::vector<product::Product>& products) {
        // Context for the client
        grpc::ClientContext context;

        // Container for the response
        google::protobuf::StringValue response;

        // Get the stream writer
        std::unique_ptr<grpc::ClientWriter<product::Product>> stream(
            stub_->updateProducts(&context, &response));

        // Send products through the stream
        for (const auto& product : products) {
            if (!stream->Write(product)) {
                // Stream has been closed
                break;
            }
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("Sent product for update: ID: {}, Name: {}\n",
                                   product.id(), product.name());
            #else
            std::cout << "Sent product for update: ID: " << product.id()
                      << ", Name: " << product.name() << std::endl;
            #endif
        }

        // Close the stream and get the response
        stream->WritesDone();
        grpc::Status status = stream->Finish();

        if (status.ok()) {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("Update Result -> {}\n", response.value());
            #else
            std::cout << "Update Result -> " << response.value() << std::endl;
            #endif
        } else {
            #if __cpp_lib_format >= 201907L
            std::cout << std::format("UpdateProducts RPC failed: {} - {}\n",
                                   static_cast<int>(status.error_code()),
                                   status.error_message());
            #else
            std::cout << "UpdateProducts RPC failed: " << status.error_code()
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

        // =========================================
	    // Get Product: Unary RPC
        client.GetProduct(id1);

        // =========================================
	    // Search products: Server streaming 
        std::cout << "\n--- Searching for 'Apple' ---" << std::endl;
        client.SearchProducts("Apple");

        // =========================================
	    // Update products: Client streaming
        std::vector<product::Product> update_products;

        // Create products to update - matching Go implementation
        product::Product upd_prod1;
        upd_prod1.set_id("101");
        upd_prod1.set_name("Samsung Galaxy S20");
        upd_prod1.set_description("C++ client");
        upd_prod1.set_price(799.00f);

        product::Product upd_prod2;
        upd_prod2.set_id("103");
        upd_prod2.set_name("Apple Watch S4");
        upd_prod2.set_description("C++ client");
        upd_prod2.set_price(399.00f);

        update_products.push_back(upd_prod1);
        update_products.push_back(upd_prod2);

        std::cout << "\n--- Updating products ---" << std::endl;
        client.UpdateProducts(update_products);

        // =========================================
	    // Process products: Bi-directional streaming

    } catch (const std::exception& e) {
        std::cerr << "Client failed with exception: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
