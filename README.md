# Puppet module for firewalling

Uses iptables as a simple firewall.

## Description

To firewall with iptables' help this module cleans up all & reinits with bash scripts. Custom parts are created in custom generated bash script. Also module adds persistency to iptables.
**Note:** Currently module was tested on Debian family.

## Usage

To allow on your managed node these things:
* SSH from home (99.100.101.102)
* web from everywhere (and in 1st order)
* some custom port from some subnet (let it be xenmgm service on port 65000 from subnet 155.56.57.0/24)

Use code like this:

```ruby
iptables::rule {
  "Allow SSH from home":
    port => "ssh", source  => "99.100.101.102";
  "Allow web":
    port => "www", action  => "insert";
  "Allow xenmgm":
    port => "65000", source  => "155.56.57.0/24";
}
```

