# Puppet module for firewalling

Uses iptables as a simple firewall.

## Description

To firewall with iptables' help this module cleans up all & reinits with bash scripts. Custom parts are created in custom generated bash script. Also module adds persistency to iptables.
**Note:** Currently module was tested on Debian family.

## Usage

### Default

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

### Many sources per rule

When you have a few sources for one port -- you can supply an array:

```ruby
iptables::rule {
  "Allow SSH from home and work":
    port => "ssh", source  => ["99.100.101.102", "56.57.58.59"];
}
```

### Rules priorities / ordering

By conception puppet does not support ordering. If you need some sort of, you
can try to play with rule's names, but it looks awful.

For this case we have plus & minus params. So by default all rules have 0 weight.
If you want to put rule ni front -- use "plus". If you want to make always last --
use minus:

```ruby
iptables::rule {
  "Web will be realy first":
    port => "www", plus => 20;
  "SSH somewhere in the middle":
    port => "ssh";
  "And mysql is always last":
    port => "3306", minus => 30;
}
```
