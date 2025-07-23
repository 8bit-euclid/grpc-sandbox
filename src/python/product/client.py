"""gRPC client for the Product Info service.

This module provides a client implementation for interacting with the Product Info
gRPC service. It demonstrates how to add and retrieve product information using
the generated protobuf stubs.
"""
import logging
import grpc
from google.protobuf import wrappers_pb2
from product import product_info_pb2 as pb2, product_info_pb2_grpc as pb2_grpc


def run():
    """Run the gRPC client to add and retrieve products, and search them."""
    # Set up a connection to the server.
    channel = grpc.insecure_channel('localhost:50051')
    stub = pb2_grpc.ProductInfoStub(channel)

    try:
        # =========================================
        # Add Products: Unary RPC
        # Product 1
        name1 = "Apple iPhone 11"
        description1 = "Python client"
        price1 = 699.00

        response1 = stub.addProduct(pb2.Product(
            name=name1,
            description=description1,
            price=price1
        ))
        logging.info("AddProduct Response -> %s", response1.value)

        # Product 2
        name2 = "Google Pixel 4a"
        description2 = "Python client"
        price2 = 399.00

        response2 = stub.addProduct(pb2.Product(
            name=name2,
            description=description2,
            price=price2
        ))
        logging.info("AddProduct Response -> %s", response2.value)

        # =========================================
        # Get Product: Unary RPC
        product = stub.getProduct(pb2.ProductID(value=response2.value))
        logging.info("GetProduct Response -> %s", product)

        # =========================================
        # Search Products: Server streaming
        search_stream = stub.searchProducts(
            wrappers_pb2.StringValue(value="Apple"))
        for search_product in search_stream:
            logging.info("Search Result -> %s", search_product)

        # =========================================
        # Update products: Client streaming
        upd_prod1 = pb2.Product(
            id="101",
            name="Samsung Galaxy S20",
            description="Python client",
            price=799.00
        )
        upd_prod2 = pb2.Product(
            id="103",
            name="Apple Watch S4",
            description="Python client",
            price=399.00
        )

        def generate_products():
            """Generator function to yield products for streaming."""
            yield upd_prod1
            yield upd_prod2

        update_result = stub.updateProducts(generate_products())
        logging.info("Update Result -> %s", update_result.value)

        # =========================================
        # Process products: Bi-directional streaming

    except grpc.RpcError as e:
        logging.error("gRPC error: %s", e)
        raise e


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    run()
