# 基础变量
BINARY_NAME=temper
BINARY_OUT_DIR=./bin
MAIN_PACKAGE=./cmd/temper

# Go 环境参数
GO111MODULE=on
CGO_ENABLED=1    # duckdb-go 需要CGO，不能关闭！
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOFMT=$(GOCMD) fmt
GOLINT=golangci-lint

# 默认目标：直接执行 make 等同于编译
all: build

## 构建二进制
build:
	@mkdir -p $(BINARY_OUT_DIR)
	CGO_ENABLED=$(CGO_ENABLED) $(GOBUILD) -o $(BINARY_OUT_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE)
	@echo "✅ 编译完成，产物: $(BINARY_OUT_DIR)/$(BINARY_NAME)"

## 运行（编译后直接启动）
run: build
	./$(BINARY_OUT_DIR)/$(BINARY_NAME)

## 运行指定命令示例：make run-init
run-init: build
	./$(BINARY_OUT_DIR)/$(BINARY_NAME) init

run-parse: build
	./$(BINARY_OUT_DIR)/$(BINARY_NAME) parse --config=temper.toml

run-plan: build
	./$(BINARY_OUT_DIR)/$(BINARY_NAME) plan --config=temper.toml

run-exec: build
	./$(BINARY_OUT_DIR)/$(BINARY_NAME) run --config=temper.toml

## 格式化全部代码
fmt:
	$(GOFMT) ./...

## 静态代码检查（需要提前安装 golangci-lint）
lint:
	$(GOLINT) run ./...

## 执行全部单元测试
test:
	$(GOTEST) -v ./...

## 仅运行单元测试，输出覆盖率
test-cov:
	$(GOTEST) -v -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out

## 清理编译产物、测试覆盖率文件
clean:
	$(GOCLEAN)
	rm -rf $(BINARY_OUT_DIR)
	rm -f coverage.out
	@echo "✅ 清理完成"

# 帮助文档，make help 查看所有命令
help:
	@echo "可用命令:"
	@echo "  make build     编译生成二进制文件"
	@echo "  make run       编译并启动 temper"
	@echo "  make run-init  执行 temper init"
	@echo "  make run-parse 配置校验"
	@echo "  make run-plan  预览执行计划"
	@echo "  make run-exec  运行完整任务"
	@echo "  make fmt       代码格式化"
	@echo "  make lint      静态代码检查"
	@echo "  make test      执行单元测试"
	@echo "  make test-cov  单元测试+覆盖率"
	@echo "  make clean     清理编译产物"

.PHONY: all build run fmt lint test test-cov clean help run-init run-parse run-plan run-exec
