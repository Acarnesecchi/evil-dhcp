package main

import (
	"fmt"
	"os/exec"
)

const (
	DEFAULT_LEASE = 600
	MAX_LEASE     = 7200
	DHCP_TEMPLATE = "evil-dhcp/dhcpd.conf.tmpl"
	DHCP_CONFIG   = "evil-dhcp/dhcpd.conf"
)

func main() {
	hostAddress, maskCIDR, iface := DiscoverNetwork()
	networkAddress := CalculateNetworkAddress(hostAddress, maskCIDR)

	// ** SINCE THIS TAKES A FEW SECONDS THIS SHOULD BE A GOROUTINE **
	cmd := exec.Command("nmap", "-sn", networkAddress+"/"+fmt.Sprint(maskCIDR))
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error running arp command:", err)
		return
	}

	devices := ParseNMAP(string(output))

	for _, device := range devices {
		fmt.Printf("IP: %s\n", device)
	}
	// ** SINCE THIS TAKES A FEW SECONDS THIS SHOULD BE A GOROUTINE **

	fmt.Printf("Network Address: %s\n", networkAddress)
	fmt.Printf("Host Address: %s\n", hostAddress)
	fmt.Printf("Subnet maskCIDR: %d\n", maskCIDR)

	config := NewConfig(networkAddress, convertMask(maskCIDR), GetDefaultGateway(iface), hostAddress)
	// we are only guessing that the router is the default gateway
	CreateConfigFile(config)
}
