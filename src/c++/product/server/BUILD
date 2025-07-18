load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "product_info_server_lib",
    srcs = [
        "product_info_server.cpp",
    ],
    hdrs = [
        "product_info_server.h",
    ],
    deps = [
        "//gen/c++/product:product_info_proto",
        "@grpc//:grpc++",
    ],
    includes = ["."],
    copts = ["-std=c++23"],
)

cc_binary(
    name = "server",
    srcs = ["main.cpp"],
    deps = [
        ":product_info_server_lib",
        "@grpc//:grpc++",
        "@grpc//:grpc++_reflection",
    ],
    copts = ["-std=c++23"],
)
