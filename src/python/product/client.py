"""gRPC client for the Product Info service.

This module provides a client implementation for interacting with the Product Info
gRPC service. It demonstrates how to add and retrieve product information using
the generated protobuf stubs.
"""
import logging
import grpc
from product import product_info_pb2 as pb2, product_info_pb2_grpc as pb2_grpc


def run():
    """Run the gRPC client to add and retrieve a product."""
    # Set up a connection to the server.
    channel = grpc.insecure_channel('localhost:50051')
    stub = pb2_grpc.ProductInfoStub(channel)

    # Contact the server and print out its response.
    name = "Apple iPhone 11"
    description = "Meet Apple iPhone 11. All-new dual-camera system with Ultra Wide and Night mode."
    price = 699.00

    try:
        response = stub.addProduct(pb2.Product(
            name=name,
            description=description,
            price=price
        ))
        logging.info("Product ID: %s added successfully", response.value)

        product = stub.getProduct(pb2.ProductID(value=response.value))
        logging.info("Product: %s", product)
    except grpc.RpcError as e:
        logging.error("gRPC error: %s", e)
        raise e


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    run()
