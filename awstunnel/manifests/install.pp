# Submódulo de instalación
class awstunnel::install {
  # Define variables
  case $::operatingsystem {
    redhat, centos: {
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    debian, ubuntu: {
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    default: {
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
  }
  # Instalación de packages
  package {'putty':
    ensure => installed,
    name   => "$puttypack",
  }
  package {'ssh':
    ensure => installed,
    name   => "$sshpack",
  }
}
