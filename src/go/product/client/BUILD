load("@rules_go//go:def.bzl", "go_binary")

# Go binary for the product client
go_binary(
    name = "client",
    srcs = ["main.go"],
    deps = [
        "//gen/go/product",
        "@org_golang_google_grpc//:grpc",
        "@org_golang_google_grpc//credentials/insecure",
        "@org_golang_google_protobuf//types/known/wrapperspb",
    ],
    visibility = ["//visibility:public"],
)
