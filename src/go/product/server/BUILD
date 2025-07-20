load("@rules_go//go:def.bzl", "go_binary")

# Go binary for the product server
go_binary(
    name = "server",
    srcs = [
        "main.go",
        "server.go",
    ],
    deps = [
        "//gen/go/product",
        "@com_github_gofrs_uuid//:uuid",
        "@org_golang_google_grpc//:grpc",
        "@org_golang_google_grpc//codes",
        "@org_golang_google_grpc//status",
    ],
    visibility = ["//visibility:public"],
)
