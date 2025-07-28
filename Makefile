# Evil DHCP - Network Security Research Tool
# Makefile for automating build and deployment tasks

# Variables
BINARY_NAME=evil-dhcp
GO_FILES=$(shell find . -name "*.go" -type f)
DHCP_IMAGE=evil-dhcp:latest
DNS_IMAGE=evil-dns:latest
DHCP_CONTAINER=evil-dhcp-server
DNS_CONTAINER=evil-dns-server
CONTAINER_TOOL?=docker

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

.PHONY: help build clean run scan docker-build docker-run docker-stop docker-clean deps check install

# Default target
all: build

## Help - Show this help message
help:
	@echo "$(BLUE)Evil DHCP - Available Make Targets$(NC)"
	@echo ""
	@echo "$(GREEN)Building:$(NC)"
	@echo "  build           - Build the Go binary"
	@echo "  deps            - Download Go dependencies"
	@echo "  clean           - Clean build artifacts and generated files"
	@echo ""
	@echo "$(GREEN)Running:$(NC)"
	@echo "  run             - Run network discovery (requires sudo)"
	@echo "  scan            - Run network scan only"
	@echo ""
	@echo "$(GREEN)Container Operations:$(NC)"
	@echo "  docker-build    - Build both DHCP and DNS container images"
	@echo "  docker-dhcp     - Build DHCP container image"
	@echo "  docker-dns      - Build DNS container image"
	@echo "  docker-run      - Start both DHCP and DNS containers"
	@echo "  docker-run-dhcp - Start DHCP container only"
	@echo "  docker-run-dns  - Start DNS container only"
	@echo "  docker-stop     - Stop all running containers"
	@echo "  docker-clean    - Remove containers and images"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  check           - Run basic checks and validation"
	@echo "  install         - Install system dependencies"
	@echo "  logs-dhcp       - View DHCP container logs"
	@echo "  logs-dns        - View DNS container logs"
	@echo ""
	@echo "$(GREEN)Configuration:$(NC)"
	@echo "  CONTAINER_TOOL  - Set to 'docker' (default) or 'podman'"
	@echo "                    Example: make CONTAINER_TOOL=podman docker-build"
	@echo ""
	@echo "$(YELLOW)Note: Many operations require sudo privileges$(NC)"

## Build the Go binary
build: $(BINARY_NAME)

$(BINARY_NAME): $(GO_FILES)
	@echo "$(GREEN)Building $(BINARY_NAME)...$(NC)"
	go build -o $(BINARY_NAME) .
	@echo "$(GREEN)Build complete!$(NC)"

## Download and verify Go dependencies
deps:
	@echo "$(GREEN)Downloading Go dependencies...$(NC)"
	go mod download
	go mod verify
	@echo "$(GREEN)Dependencies updated!$(NC)"

## Run network discovery (requires sudo)
run: build
	@echo "$(YELLOW)Running network discovery (requires sudo)...$(NC)"
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "$(RED)Error: This command requires sudo privileges$(NC)"; \
		echo "$(YELLOW)Please run: sudo make run$(NC)"; \
		exit 1; \
	fi
	./$(BINARY_NAME)

## Run network scan only (for testing)
scan: build
	@echo "$(GREEN)Running network scan...$(NC)"
	./$(BINARY_NAME) 2>/dev/null | grep -E "(IP:|Network|Host|Subnet)" || true

## Build all Docker images
docker-build: docker-dhcp docker-dns

## Build DHCP container image
docker-dhcp:
	@echo "$(GREEN)Building DHCP container image...$(NC)"
	cd evil-dhcp && $(CONTAINER_TOOL) build -t $(DHCP_IMAGE) .
	@echo "$(GREEN)DHCP image built successfully!$(NC)"

## Build DNS container image
docker-dns:
	@echo "$(GREEN)Building DNS container image...$(NC)"
	cd evil-dns && $(CONTAINER_TOOL) build -t $(DNS_IMAGE) .
	@echo "$(GREEN)DNS image built successfully!$(NC)"

## Start both DHCP and DNS containers
docker-run: docker-run-dhcp docker-run-dns

## Start DHCP container
docker-run-dhcp: docker-dhcp
	@echo "$(GREEN)Starting DHCP container...$(NC)"
	@$(CONTAINER_TOOL) stop $(DHCP_CONTAINER) 2>/dev/null || true
	@$(CONTAINER_TOOL) rm $(DHCP_CONTAINER) 2>/dev/null || true
	$(CONTAINER_TOOL) run -d --name $(DHCP_CONTAINER) --network host $(DHCP_IMAGE)
	@echo "$(GREEN)DHCP container started!$(NC)"
	@echo "$(YELLOW)Use 'make logs-dhcp' to view logs$(NC)"

## Start DNS container
docker-run-dns: docker-dns
	@echo "$(GREEN)Starting DNS container...$(NC)"
	@$(CONTAINER_TOOL) stop $(DNS_CONTAINER) 2>/dev/null || true
	@$(CONTAINER_TOOL) rm $(DNS_CONTAINER) 2>/dev/null || true
	$(CONTAINER_TOOL) run -d --name $(DNS_CONTAINER) -p 53:53/udp $(DNS_IMAGE)
	@echo "$(GREEN)DNS container started!$(NC)"
	@echo "$(YELLOW)Use 'make logs-dns' to view logs$(NC)"

## Stop all containers
docker-stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@$(CONTAINER_TOOL) stop $(DHCP_CONTAINER) $(DNS_CONTAINER) 2>/dev/null || true
	@echo "$(GREEN)Containers stopped!$(NC)"

## Clean up containers and images
docker-clean: docker-stop
	@echo "$(YELLOW)Cleaning up container resources...$(NC)"
	@$(CONTAINER_TOOL) rm $(DHCP_CONTAINER) $(DNS_CONTAINER) 2>/dev/null || true
	@$(CONTAINER_TOOL) rmi $(DHCP_IMAGE) $(DNS_IMAGE) 2>/dev/null || true
	@echo "$(GREEN)Container cleanup complete!$(NC)"

## View DHCP container logs
logs-dhcp:
	@echo "$(BLUE)DHCP Container Logs:$(NC)"
	@$(CONTAINER_TOOL) logs -f $(DHCP_CONTAINER) 2>/dev/null || echo "$(RED)DHCP container not running$(NC)"

## View DNS container logs
logs-dns:
	@echo "$(BLUE)DNS Container Logs:$(NC)"
	@$(CONTAINER_TOOL) logs -f $(DNS_CONTAINER) 2>/dev/null || echo "$(RED)DNS container not running$(NC)"

## Run basic checks and validation
check:
	@echo "$(GREEN)Running basic checks...$(NC)"
	@echo "$(BLUE)Checking Go version:$(NC)"
	@go version
	@echo "$(BLUE)Checking $(CONTAINER_TOOL):$(NC)"
	@$(CONTAINER_TOOL) --version
	@echo "$(BLUE)Checking nmap:$(NC)"
	@nmap --version | head -n1
	@echo "$(BLUE)Checking for required files:$(NC)"
	@test -f evil-dhcp/dhcpd.conf.tmpl && echo "✓ DHCP template found" || echo "✗ DHCP template missing"
	@test -f evil-dns/db.example.com.tmpl && echo "✓ DNS template found" || echo "✗ DNS template missing"
	@test -f evil-dhcp/Dockerfile && echo "✓ DHCP Dockerfile found" || echo "✗ DHCP Dockerfile missing"
	@test -f evil-dns/Dockerfile && echo "✓ DNS Dockerfile found" || echo "✗ DNS Dockerfile missing"
	@echo "$(GREEN)Checks complete!$(NC)"

## Install system dependencies (Ubuntu/Debian/RHEL)
install:
	@echo "$(GREEN)Installing system dependencies...$(NC)"
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "$(BLUE)Installing via apt-get...$(NC)"; \
		sudo apt-get update; \
		if [ "$(CONTAINER_TOOL)" = "podman" ]; then \
			sudo apt-get install -y podman nmap golang-go; \
		else \
			sudo apt-get install -y docker.io nmap golang-go; \
			sudo systemctl enable docker; \
			sudo systemctl start docker; \
			sudo usermod -aG docker $$USER; \
			echo "$(YELLOW)Note: You may need to log out and back in for Docker group changes to take effect$(NC)"; \
		fi; \
	elif command -v dnf >/dev/null 2>&1; then \
		echo "$(BLUE)Installing via dnf...$(NC)"; \
		if [ "$(CONTAINER_TOOL)" = "podman" ]; then \
			sudo dnf install -y podman nmap golang; \
		else \
			sudo dnf install -y docker nmap golang; \
			sudo systemctl enable docker; \
			sudo systemctl start docker; \
			sudo usermod -aG docker $$USER; \
		fi; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "$(BLUE)Installing via yum...$(NC)"; \
		if [ "$(CONTAINER_TOOL)" = "podman" ]; then \
			sudo yum install -y podman nmap golang; \
		else \
			sudo yum install -y docker nmap golang; \
			sudo systemctl enable docker; \
			sudo systemctl start docker; \
			sudo usermod -aG docker $$USER; \
		fi; \
	else \
		echo "$(RED)Unsupported package manager. Please install $(CONTAINER_TOOL), nmap, and Go manually.$(NC)"; \
	fi

## Clean build artifacts and generated files
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@rm -f $(BINARY_NAME)
	@rm -f dhcpd.conf
	@rm -f evil-dhcp/dhcpd.conf
	@rm -f evil-dns/db.example.com
	@echo "$(GREEN)Cleanup complete!$(NC)"

## Development workflow - full setup
dev-setup: deps check docker-build
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "$(YELLOW)Run 'sudo make run' to start network discovery$(NC)"

## Production deployment (generates configs and starts services)
deploy: build run docker-build docker-run
	@echo "$(GREEN)Deployment complete!$(NC)"
	@echo "$(BLUE)Services running:$(NC)"
	@$(CONTAINER_TOOL) ps --filter name=evil- --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

## Show container status
status:
	@echo "$(BLUE)Container Status:$(NC)"
	@$(CONTAINER_TOOL) ps --filter name=evil- --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"

## Quick test - scan network and show results
test: build
	@echo "$(GREEN)Running quick network test...$(NC)"
	@echo "$(BLUE)Network Discovery Results:$(NC)"
	@timeout 30s ./$(BINARY_NAME) 2>/dev/null || echo "$(YELLOW)Scan completed or timed out$(NC)"