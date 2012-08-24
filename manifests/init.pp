# @see https://help.ubuntu.com/community/IptablesHowTo

class iptables {

  package {"iptables":
    ensure  => present,
  }

  file {
    "/usr/bin/iptables_setup":
      source  => "puppet:///modules/iptables/iptables_setup_init.sh",
      mode    => 755;
    "/etc/iptables_setup.d":
      recurse => true,
      purge   => true,
      ensure  => directory;
    "/etc/network/if-pre-up.d/iptables_persistency_restore":
      ensure  => present,
      source  => "puppet:///modules/iptables/iptables_persistency_restore.sh",
      mode    => 755;
    "/etc/network/if-post-down.d/iptables_persistency_save":
      ensure  => present,
      source  => "puppet:///modules/iptables/iptables_persistency_save.sh",
      mode    => 755;
  }

  exec {"Finishing iptables":
    require   => File["/usr/bin/iptables_setup"],
    command   => "/usr/bin/iptables_setup",
    cwd       => "/etc/iptables_setup.d",
    refreshonly => true,
  }

}

define iptables::rule(
  $port,
  $source = ["0.0.0.0/0"],
  $action = "append",
  $plus   = undef,
  $minus  = undef
) {

  include iptables

  if $plus {
    $weight = $plus
  } else {
    if $minus {
      $weight = "-$minus"
    } else {
      $weight = 0
    }
  }
  $file_name = regsubst($name, '\s+', '_', 'EG')

  file {"Adding iptables rule for $port and $source":
    require   => File["/etc/iptables_setup.d"],
    path      => "/etc/iptables_setup.d/${weight}_${file_name}",
    content   => template("iptables/rule.erb"),
    notify    => Exec["Finishing iptables"],
  }

}
