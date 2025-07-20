load("@rules_python//python:defs.bzl", "py_binary")

# Use the generated proto library from gen/python/product
# This references the generated library which is recreated by 'buf generate'

# Product server binary
py_binary(
    name = "server",
    srcs = ["server.py"],
    main = "server.py",
    deps = [
        "//gen/python/product:product_py_proto",
    ],
    visibility = ["//visibility:public"],
)

# Product client binary
py_binary(
    name = "client",
    srcs = ["client.py"],
    main = "client.py",
    deps = [
        "//gen/python/product:product_py_proto",
    ],
    visibility = ["//visibility:public"],
)
