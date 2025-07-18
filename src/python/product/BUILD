load("@rules_python//python:defs.bzl", "py_binary")

# Product server binary
py_binary(
    name = "server",
    srcs = ["server.py"],
    main = "server.py",
    deps = [
        "//gen/python:product_py_proto",
    ],
)

# Product client binary
py_binary(
    name = "client",
    srcs = ["client.py"],
    main = "client.py",
    deps = [
        "//gen/python:product_py_proto",
    ],
)
