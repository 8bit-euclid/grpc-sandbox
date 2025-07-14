import logging
import uuid
from concurrent import futures
import grpc
from gen.python.product import product_info_pb2, product_info_pb2_grpc


class ProductInfoServicer(product_info_pb2_grpc.ProductInfoServicer):
    def __init__(self):
        self.product_map = {}

    def addProduct(self, request, context):
        product_id = str(uuid.uuid4())
        product = product_info_pb2.Product(
            id=product_id,
            name=request.name,
            description=request.description,
            price=request.price
        )
        self.product_map[product_id] = product
        logging.info(f"Product {product_id} : {product.name} - Added.")
        return product_info_pb2.ProductID(value=product_id)

    def getProduct(self, request, context):
        product = self.product_map.get(request.value)
        if product:
            logging.info(f"Product {product.id} : {product.name} - Retrieved.")
            return product
        context.abort(grpc.StatusCode.NOT_FOUND,
                      f"Product with ID {request.value} does not exist.")


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    product_info_pb2_grpc.add_ProductInfoServicer_to_server(
        ProductInfoServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    logging.info("Server started on port 50051.")
    server.wait_for_termination()


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    serve()
