# Root BUILD file for gRPC Sandbox
# This file provides convenient build targets for all languages
# Generated files in gen/ are created by 'buf generate' and don't need BUILD files

# Filegroup for all generated protobuf files (for reference)
filegroup(
    name = "generated_protos",
    srcs = glob([
        "gen/**/*.pb.go",
        "gen/**/*.pb.h",
        "gen/**/*.pb.cc",
        "gen/**/*.grpc.pb.go",
        "gen/**/*.grpc.pb.h",
        "gen/**/*.grpc.pb.cc",
        "gen/**/*_pb2.py",
        "gen/**/*_pb2_grpc.py",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

# Alias targets for convenient building
alias(
    name = "python_server",
    actual = "//src/python/product:server",
    visibility = ["//visibility:public"],
)

alias(
    name = "python_client",
    actual = "//src/python/product:client",
    visibility = ["//visibility:public"],
)

alias(
    name = "go_server",
    actual = "//src/go/product/server:server",
    visibility = ["//visibility:public"],
)

alias(
    name = "go_client",
    actual = "//src/go/product/client:client",
    visibility = ["//visibility:public"],
)

alias(
    name = "cpp_server",
    actual = "//src/c++/product/server:server",
    visibility = ["//visibility:public"],
)

alias(
    name = "cpp_client",
    actual = "//src/c++/product/client:client",
    visibility = ["//visibility:public"],
)
