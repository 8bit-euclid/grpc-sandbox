load("@rules_python//python:defs.bzl", "py_binary", "py_library")

# Python proto library for product_info (references generated files)
py_library(
    name = "product_info_py_proto",
    srcs = [
        "//gen/python/product:product_info_pb2.py",
        "//gen/python/product:product_info_pb2_grpc.py",
    ],
    imports = ["gen/python"],
    deps = [
        "@pip//grpcio:pkg",
        "@pip//protobuf:pkg",
    ],
)

# Product server binary
py_binary(
    name = "server",
    srcs = ["server.py"],
    main = "server.py",
    deps = [
        ":product_info_py_proto",
    ],
)

# Product client binary
py_binary(
    name = "client",
    srcs = ["client.py"],
    main = "client.py",
    deps = [
        ":product_info_py_proto",
    ],
)
