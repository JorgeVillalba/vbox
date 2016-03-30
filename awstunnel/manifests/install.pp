# Submódulo de instalación
class awstunnel::install {
  # Instalación de packages
  package {'puppet':
    ensure => installed,
    name   => "$awstunnel::params::puppetpack",
  }
  package {'putty':
    ensure => installed,
    name   => "$awstunnel::params::puttypack",
  }
  package {'ssh':
    ensure => installed,
    name   => "$awstunnel::params::sshpack",
  }
}
