# Submódulo de instalación
class awstunnel::service {
  # Definición del servicio y crontab
  service {'awstunneld':
    ensure     => running,
    enable     => true,
    path       => "$awstunnel::params::initdpath",
    hasstatus  => true,
    hasrestart => true,
    stop       => "$awstunnel::params::servicepath stop",
    start      => "$awstunnel::params::servicepath start",
    status     => "$awstunnel::params::servicepath status",
    restart    => "$awstunnel::params::servicepath restart",
    require    => File['awstunneld'],
  }
  cron {'awstunnel':
    command     => "sh -x $awstunnel::params::servicepath status >/tmp/tunnel.log 2>&1",
    user        => 'jorge',
    hour        => '*',
    minute      => '*/1',
    environment => "PATH=$::path:.",
  }
}
