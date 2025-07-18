import grpc
import logging
from product import product_info_pb2 as pb2, product_info_pb2_grpc as pb2_grpc


def run():
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
        logging.info(f"Product ID: {response.value} added successfully")

        product = stub.getProduct(
            pb2.ProductID(value=response.value))
        logging.info(f"Product: {product}")
    except grpc.RpcError as e:
        logging.error(f"gRPC error: {e.code()} - {e.details()}")


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    run()
