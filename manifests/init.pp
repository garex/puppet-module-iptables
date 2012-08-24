# @see https://help.ubuntu.com/community/IptablesHowTo

class iptables {

  package {"iptables":
    ensure  => present,
  }
  
  file {
    "/usr/bin/iptables_setup":
      source  => "puppet:///modules/iptables/iptables_setup_init.sh",
      mode    => 755;
    "/usr/bin/iptables_setup_custom":
      content => "";
    "/etc/network/if-pre-up.d/iptables_persistency_restore":
      ensure  => present,
      source  => "puppet:///modules/iptables/iptables_persistency_restore.sh",
      mode    => 755;
    "/etc/network/if-post-down.d/iptables_persistency_save":
      ensure  => present,
      source  => "puppet:///modules/iptables/iptables_persistency_save.sh",
      mode    => 755;
  }
  
  class {"iptables::finish":}

}

define iptables::rule($port, $source = "0.0.0.0/0", $action = "append") {

  include iptables

  # Dependency on class
  Class[ "iptables" ] -> Rule[ $name ] -> Class[ "iptables::finish" ]

  exec {"Adding iptables rule for $port and $source":
    command => "/bin/echo iptables --$action INPUT --jump ACCEPT --in-interface eth0 --proto tcp --dport $port --source $source >> /usr/bin/iptables_setup_custom",
  }
  
}

class iptables::finish {
  
  exec {"Finishing iptables":
    command => "/usr/bin/iptables_setup",
  }
  
}