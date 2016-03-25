# Submódulo de configuraciones
class awstunnel::config {
  # Define variables
  $usuario     = 'jorge'
  $grupo       = 'vboxsf'
  $homeusuario = "/home/$usuario"
  case $::operatingsystem {
    redhat, centos: {
      $certspath   = "$homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
    }
    debian, ubuntu: {
      $certspath   = "$homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
    }
    default: {
      $certspath   = "$homeusuario/certs"
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $prxsysdir   = '/etc/apt'
      $prxsysconf  = 'apt.conf'
    }
  }
  # Configuraciones
  file {'basetoolscripts':
    ensure => directory,
    path   => "$basescripts",
    mode   => '0755',
    owner  => "$usuario",
    group  => "$grupo",
  }
  file {'toolscripts':
    ensure => directory,
    path   => "$scriptspath",
    mode   => '0755',
    owner  => "$usuario",
    group  => "$grupo",
    require => File['basetoolscripts'],
  }
  file {'certspath':
    ensure   => directory,
    path     => "$certspath",
    mode   => '0755',
    owner  => "$usuario",
    group  => "$grupo",
  }
  file {'ppk':
    ensure  => file,
    path    => "$certspath/keyfile.ppk",
    require => File['certspath'],
    source  => "puppet:///modules/$module_name/keyfile.ppk",
    mode   => '0755',
    owner  => "$usuario",
    group  => "$grupo",
  }
  file {'etc':
    ensure  => directory,
    path    => '/etc',
    mode    => '0775',
    owner   => 'root',
    group   => "$grupo",
  }
  file {'apt':
    ensure  => directory,
    path    => "$prxsysdir",
    mode    => '0775',
    owner   => 'root',
    group   => "$grupo",
    require => File['etc'],
  }
  file {'aptconf':
    ensure  => file,
    path    => "$prxsysdir/$prxsysconf",
    mode    => '0664',
    owner   => 'root',
    group   => "$grupo",
    require => File['apt'],
  }
  file {'awstunneld':
    ensure  => file,
    path    => "$servicepath",
    owner   => "$usuario",
    group   => "$grupo",
    mode    => '0755',
    content => "#!/bin/bash

export USER=\"$usuario\"
export HOME=`grep \${USER} /etc/passwd | awk -F: {'print \$6'}`
export DISPLAY=:0.0
export PATHTOCERT=\${HOME}'/certs'
export CERT=\${PATHTOCERT}/keyfile.ppk
export LPORT='8081'
export RPORT='22'
export REMOTEHOST='52.31.107.108'
export REMOTEUSER='ec2-user'
export PATH=\"$::path\"
export BINPATH='/usr/bin'
export PRXSYSDIR=$prxsysdir
export PRXSYSCONF=\${PRXSYSDIR}/$prxsysconf
export PID=`sudo -u root lsof -nPi:\${LPORT} | grep LISTEN | head -1 | awk {'print \$2'}`

xhost +

start() {
  sudo -u root putty -ssh -i \${CERT} -D \${LPORT} -P \${RPORT} -l \${REMOTEUSER} \${REMOTEHOST} &
  if [ ! -d \${PRXSYSDIR} ]; then
    sudo -u root mkdir \${PRXSYSDIR}
    sudo -u root chmod 777 \${PRXSYSDIR}
  fi
  sudo -u root echo 'Acquire::socks::proxy \"socks://127.0.0.1:'\${LPORT}'/\";' > \${PRXSYSCONF}
}

stop() {
  sudo -u root kill -9 \${PID}
  if [ -f \${PRXSYSCONF} ]; then
    sudo -u root echo \"\" > \${PRXSYSCONF}
  fi
}

status() {
  if [ `sudo -u root lsof -nPi:\${LPORT} | grep LISTEN | wc -l` -lt 2 ]; then
    echo -e '\\nAL: Túnel AWS, puerto '\${LPORT}': CERRADO.\\n'
    start
    exit 1
  else
    echo -e '\\nOK: Túnel AWS, puerto '\${LPORT}': ABIERTO, PID '\${PID}'.\\n'
    exit 0
  fi
}

case \$1 in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status
        ;;
  restart)
        stop
        sleep 5
        start
        ;;
  *)
        echo 'Uso: \$0 [start|stop|status|restart]'
        exit 1
esac",
  }
}
