#include <iostream>
#include <memory>
#include <string>
#include <format>

#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>
#include <grpcpp/ext/proto_server_reflection_plugin.h>

#include "product_info_server.h"

namespace {
    constexpr const char* kServerAddress = "0.0.0.0:50051";
}

void RunServer() {
    // Create the service implementation
    productinfo::ProductInfoServer service;

    // Configure the server
    grpc::ServerBuilder builder;
    
    // Listen on the given address without any authentication mechanism
    builder.AddListeningPort(kServerAddress, grpc::InsecureServerCredentials());
    
    // Register the service
    builder.RegisterService(&service);
    
    // Enable health checking service
    grpc::EnableDefaultHealthCheckService(true);
    
    // Enable server reflection (useful for debugging with grpcurl)
    grpc::reflection::InitProtoReflectionServerBuilderPlugin();
    
    // Build and start the server
    std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
    
    if (!server) {
        std::cerr << "Failed to start server" << std::endl;
        return;
    }
    
    // Log server startup using C++23 std::format (if available) or fallback
    #if __cpp_lib_format >= 201907L
    std::cout << std::format("Server is listening on {}\n", kServerAddress);
    #else
    std::cout << "Server is listening on " << kServerAddress << std::endl;
    #endif
    
    // Wait for the server to shutdown. Note that some other thread must be
    // responsible for shutting down the server for this call to ever return.
    server->Wait();
}

int main(int argc, char** argv) {
    try {
        RunServer();
    } catch (const std::exception& e) {
        std::cerr << "Server failed with exception: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
