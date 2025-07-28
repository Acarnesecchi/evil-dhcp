# Evil DHCP - Network Security Research Tool

## 🚨 Disclaimer
This tool is designed for **educational purposes and authorized network security testing only**. Using this tool on networks you don't own or without explicit permission is illegal and unethical. Always ensure you have proper authorization before conducting any network security research.

## 📖 Overview

Evil DHCP is an experimental network security research tool that demonstrates how rogue DHCP and DNS servers can be deployed for network analysis and penetration testing. The tool automatically discovers network topology, scans for devices, and sets up containerized rogue services.

### 🎯 Project Purpose

This project explores the theoretical concept of:
- **Rogue DHCP Server Deployment**: Automatically configuring and deploying a DHCP server that can intercept network requests
- **DNS Manipulation**: Setting up a custom DNS server for traffic redirection
- **Network Discovery**: Automated network topology mapping and device enumeration
- **Container-based Infrastructure**: Using Docker for isolated and portable service deployment

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Go Controller │────│   DHCP Server    │────│   DNS Server    │
│                 │    │   (Container)    │    │   (Container)   │
│ - Network Scan  │    │ - ISC DHCP       │    │ - BIND9         │
│ - Config Gen    │    │ - Dynamic Range  │    │ - Custom Zones  │
│ - Orchestration │    │ - Lease Mgmt     │    │ - Resolution    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🔧 Current Implementation

### ✅ Completed Features
- **Network Discovery**: Automatically detects host IP, subnet mask, and network interface
- **Device Enumeration**: Uses nmap to scan and identify devices on the network
- **Configuration Generation**: Creates DHCP server configurations using Go templates
- **Container Setup**: Docker configurations for both DHCP and DNS servers
- **Gateway Detection**: Automatically identifies the default gateway

### 🚧 What Needs to be Finished

#### High Priority
1. **DHCP Range Calculation**:
   - Currently `RangeStart` and `RangeEnd` are empty strings
   - Need to implement logic to calculate available IP ranges
   - Should exclude gateway, broadcast, and known devices

2. **Goroutine Implementation**:
   - Network scanning is currently synchronous
   - Comments indicate nmap scanning should use goroutines for performance

3. **DNS Template Processing**:
   - DNS zone templates exist but aren't being generated
   - Need to implement DNS configuration generation similar to DHCP

#### Medium Priority
4. **Error Handling**: Improve robustness with better error handling
5. **Logging System**: Add structured logging for debugging and monitoring
6. **Configuration Validation**: Validate generated configurations before deployment
7. **Service Orchestration**: Automated Docker container management

#### Nice to Have
8. **CLI Interface**: Command-line flags for customization
9. **Multiple Interface Support**: Handle systems with multiple network interfaces
10. **Traffic Monitoring**: Real-time monitoring of DHCP/DNS requests

## 🤖 Automation Features

This project includes a comprehensive `Makefile` that automates common tasks:

- **One-command setup**: `make dev-setup` installs dependencies and builds everything
- **Simplified deployment**: `make deploy` runs discovery and starts all services  
- **Container management**: Build, run, stop, and clean containers with simple commands (supports both Docker and Podman)
- **Development workflow**: Automatic dependency management and build optimization
- **System integration**: Automated installation of system dependencies
- **Monitoring**: Easy access to container logs and service status
- **Safety checks**: Validates prerequisites and provides helpful error messages

Run `make help` to see all available commands with descriptions.

## 🚀 Getting Started

### Prerequisites
- Go 1.22.1 or later
- Docker or Podman (container engine)
- nmap installed on the system
- Root/sudo privileges (required for DHCP server operations)

### Installation
```bash
git clone https://github.com/your-username/evil-dhcp.git
cd evil-dhcp
make deps
```

### Quick Start with Makefile
```bash
# Show all available commands
make help

# Install system dependencies (Ubuntu/Debian)
make install

# Set up development environment
make dev-setup

# Run network discovery and configuration generation
sudo make run

# Build and start all services
make deploy

# View service status
make status

# Stop all services
make docker-stop

# Use Podman instead of Docker
make CONTAINER_TOOL=podman docker-build
make CONTAINER_TOOL=podman docker-run
```

### Manual Usage (if not using Makefile)
```bash
# Run network discovery and configuration generation
sudo go run .

# Build and run DHCP container
cd evil-dhcp
docker build -t evil-dhcp .
docker run --rm --network host evil-dhcp

# Build and run DNS container
cd evil-dns
docker build -t evil-dns .
docker run --rm -p 53:53/udp evil-dns
```

## 📁 Project Structure

```
evil-dhcp/
├── main.go                 # Entry point and orchestration
├── net.go                  # Network discovery and scanning
├── tmpl.go                 # Configuration template processing
├── utils.go                # Utility functions (IP/mask conversion)
├── Makefile               # Build automation and task management
├── go.mod                 # Go module dependencies
├── evil-dhcp/
│   ├── dhcpd.conf.tmpl    # DHCP server configuration template
│   ├── Dockerfile         # DHCP server container
│   └── dhcpd.conf         # Generated DHCP configuration
├── evil-dns/
│   ├── named.conf.local   # DNS zone configuration
│   ├── db.example.com.tmpl # DNS zone template
│   ├── Dockerfile         # DNS server container
│   └── named.conf.options # DNS server options
└── README.md              # This file
```

## 🧪 Testing Scenarios

Once completed, this tool could be used for:

1. **DHCP Starvation Testing**: Exhaust legitimate DHCP pools
2. **Man-in-the-Middle Setup**: Redirect traffic through controlled infrastructure
3. **DNS Hijacking Simulation**: Demonstrate DNS-based attacks
4. **Network Segmentation Validation**: Test network isolation controls
5. **DHCP Snooping Verification**: Validate DHCP security features

## ⚡ Performance Considerations

- **Concurrent Scanning**: Implement goroutines for network operations
- **Resource Management**: Proper container lifecycle management
- **Memory Usage**: Efficient handling of large network scans
- **Network Impact**: Minimize disruption to production networks

## 🤝 Contributing

This is an experimental project perfect for learning network security concepts. Areas where contributions would be valuable:

1. **Core Functionality**: Complete the missing features listed above
2. **Security Features**: Add detection avoidance mechanisms
3. **Monitoring**: Implement comprehensive logging and monitoring
4. **Documentation**: Expand technical documentation and examples
5. **Testing**: Create automated tests for network scenarios

## 📚 Educational Value

This project demonstrates several important networking and security concepts:

- **DHCP Protocol**: How dynamic IP allocation works
- **DNS Resolution**: Custom DNS server implementation
- **Network Discovery**: Automated topology mapping
- **Containerization**: Service isolation and deployment
- **Go Networking**: Systems programming in Go
- **Security Research**: Responsible disclosure and testing practices

## 🔐 Security Considerations

- Always test in isolated environments first
- Understand legal implications in your jurisdiction
- Document and report vulnerabilities responsibly
- Never deploy on networks without authorization
- Consider network impact and availability

## 📄 License

This project is for educational and research purposes. Please use responsibly and in accordance with applicable laws and regulations.

---

**Note**: This is an experimental project that demonstrates network security concepts. The author is not responsible for any misuse of this tool.