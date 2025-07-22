"""gRPC server for the Product Info service.

This module provides a server implementation for the Product Info service.
It demonstrates how to add and retrieve product information using the generated
protobuf stubs.
"""
import logging
import uuid
from concurrent import futures
import grpc
from google.protobuf import wrappers_pb2
from product import product_info_pb2 as pb2, product_info_pb2_grpc as pb2_grpc


class ProductInfoServicer(pb2_grpc.ProductInfoServicer):
    """ProductInfo service implementation."""

    def __init__(self):
        self.product_map = {}

    def addProduct(self, request, context):
        product_id = str(uuid.uuid4())
        product = pb2.Product(
            id=product_id,
            name=request.name,
            description=request.description,
            price=request.price
        )
        self.product_map[product_id] = product
        logging.info(f"Product {product_id} : {product.name} - Added.")
        return pb2.ProductID(value=product_id)

    def getProduct(self, request, context):
        product = self.product_map.get(request.value)
        if product:
            logging.info(f"Product {product.id} : {product.name} - Retrieved.")
            return product
        context.abort(grpc.StatusCode.NOT_FOUND,
                      f"Product with ID {request.value} does not exist.")

    def searchProducts(self, request, context):
        """Search products by name and description using server streaming."""
        search_query = request.value

        for key, product in self.product_map.items():
            logging.info(f"{key} {product}")
            item_str = product.name + " " + product.description
            if search_query.lower() in item_str.lower():
                # Send the matching product in the stream
                yield product
                logging.info(f"Matching Product Found : {key}")

    def updateProducts(self, request_iterator, context):
        """Update products using client streaming."""
        orders_str = "Updated Order IDs : "

        for product in request_iterator:
            # Update product in the map
            self.product_map[product.id] = product
            logging.info(f"Order ID : {product.id} - Updated")
            orders_str += product.id + ", "

        # Return the final response
        return wrappers_pb2.StringValue(value=f"Orders processed {orders_str}")


def serve():
    """Start the gRPC server."""
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    pb2_grpc.add_ProductInfoServicer_to_server(
        ProductInfoServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    logging.info("Server started on port 50051.")
    server.wait_for_termination()


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    serve()
