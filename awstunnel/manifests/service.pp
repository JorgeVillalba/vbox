# Submódulo de instalación
class awstunnel::service {
  # Define variables
  case $::operatingsystem {
    redhat, centos: {
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
    }
    debian, ubuntu: {
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
    }
    default: {
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
    }
  }
  service {'awstunneld':
    ensure     => running,
    #name       => 'awstunneld',
    enable     => true,
    path       => "$initdpath",
    hasstatus  => true,
    hasrestart => true,
    stop       => "$servicepath stop",
    start      => "$servicepath start",
    status     => "$servicepath status",
    restart    => "$servicepath restart",
    require    => File['awstunneld'],
  }
  cron {'awstunnel':
    command     => "sh -x $servicepath status >/tmp/tunnel.log 2>&1",
    user        => 'jorge',
    hour        => '*',
    minute      => '*/1',
    environment => "PATH=$::path:.",
  }
}
