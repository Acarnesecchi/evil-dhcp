package main

import (
	"os"
	"text/template"
)

type DHCPConfig struct {
	Subnet       string
	Netmask      string
	RangeStart   string
	RangeEnd     string
	Router       string
	DNSServer    string
	DefaultLease int
	MaxLease     int
}

func CreateConfigFile(config DHCPConfig) {
	tmpl, err := template.ParseFiles(DHCP_TEMPLATE)
	if err != nil {
		panic(err)
	}

	// Execute the template with the configuration data and write the result to a file
	file, err := os.Create("evil-dhcp/dhcpd.conf")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	err = tmpl.Execute(file, config)
	if err != nil {
		panic(err)
	}
}

func NewConfig(net, mask, gw, host string) DHCPConfig {
	return DHCPConfig{
		Subnet:       net,
		Netmask:      mask,
		RangeStart:   "",
		RangeEnd:     "",
		Router:       gw,
		DNSServer:    host,
		DefaultLease: DEFAULT_LEASE,
		MaxLease:     MAX_LEASE,
	}
}
