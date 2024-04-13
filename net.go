package main

import (
	"fmt"
	"net"
	"strings"

	"github.com/bitfield/script"
)

func DiscoverNetwork() (string, int, string) {

	interfaces, err := net.Interfaces()
	if err != nil {
		fmt.Println("Error getting network interfaces:", err)
		return "", 0, ""
	}

	for _, iface := range interfaces {
		addrs, err := iface.Addrs()
		if err != nil {
			fmt.Println("Error getting addresses for interface:", iface.Name, err)
			continue
		}

		for _, addr := range addrs {
			switch v := addr.(type) {
			case *net.IPNet:
				if v.IP.To4() != nil && !v.IP.IsLoopback() {
					return v.IP.String(), convertHexToBits(v.Mask.String()), iface.Name
				}
			}
		}
	}

	return "", 0, ""
}

func ParseNMAP(output string) []string {
	lines := strings.Split(output, "\n")
	var ips []string

	for _, line := range lines {
		if strings.Contains(line, "Nmap scan report for") {
			elements := strings.Split(line, " ")
			ip := strings.Trim(elements[len(elements)-1], "()") // gateway and self are in parentheses
			ips = append(ips, ip)
		}
	}
	return ips
}

func CalculateNetworkAddress(hostAddress string, mask int) string {
	hostIP := net.ParseIP(hostAddress).To4()
	maskIP := net.ParseIP(convertMask(mask)).To4()

	networkIP := make(net.IP, 4)
	for i := 0; i < 4; i++ {
		networkIP[i] = hostIP[i] & maskIP[i]
	}

	return networkIP.String()
}

func GetDefaultGateway(iface string) string {
	output, error := script.Exec("ip route show default").Match(iface).Column(3).First(1).String()
	if error != nil {
		fmt.Println("Error getting default gateway:", error)
		return ""
	}
	return strings.Trim(output, "\n")
}
