# Submódulo para definir parámetros y variables
class awstunnel::params {
  # Define variables
  $usuario     = 'jorge'
  $grupo       = 'vboxsf'
  $homeusuario = "/home/$usuario"
  $confuser    = "$homeusuario/conf"
  $bashconf    = 'bash.config'
  case $::operatingsystem {
    redhat, centos: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
      $certspath   = "$awstunnel::params::homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
    }
    debian, ubuntu: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
      $certspath   = "$awstunnel::params::homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
      #notify {'ESTAMOS DEFINIENDO VARIABLES DE UBUNTU': }
    }
    default: {
      $puppetpack  = 'puppet'
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
      $certspath   = "$awstunnel::params::homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
    }
  }
}
