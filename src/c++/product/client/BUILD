load("@rules_cc//cc:defs.bzl", "cc_binary")

cc_binary(
    name = "client",
    srcs = ["main.cpp"],
    deps = [
        "//gen/c++/product:product_proto",
        "@grpc//:grpc++",
    ],
    copts = ["-std=c++23"],
    visibility = ["//visibility:public"],
)
