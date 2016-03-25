# Submódulo de instalación
class awstunnel::install {
  # Define variables
  case $::operatingsystem {
    redhat, centos: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    debian, ubuntu: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    default: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
  }
  # Instalación de packages
  package {'puppet':
    ensure => installed,
    name   => "$puppetpack",
  }
  package {'putty':
    ensure => installed,
    name   => "$puttypack",
  }
  package {'ssh':
    ensure => installed,
    name   => "$sshpack",
  }
}
