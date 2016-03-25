class awstunnel {
  # Define variables
  case $::operatingsystem {
    redhat, centos: {
      $certspath   = '/root/certs'
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    debian, ubuntu: {
      $certspath   = '/root/certs'
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
      $puttypack   = 'putty'
      $sshpack     = 'ssh'
    }
    default: {
      $certspath   = '/root/certs'
      $initdpath   = '/etc/init.d'
      $servicepath = "$initdpath/awstunneld"
      $basescripts = '/tools'
      $scriptspath = "$basescripts/scripts"
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
  # Configuraciones
  file {'basetoolscripts':
    ensure => directory,
    path   => "$basescripts",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file {'toolscripts':
    ensure => directory,
    path   => "$scriptspath",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    require => File['basetoolscripts'],
  }
  file {'certspath':
    ensure   => directory,
    path     => "$certspath",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file {'ppk':
    ensure  => file,
    path    => "$certspath/keyfile.ppk",
    require => File['certspath'],
    source  => "puppet:///modules/awstunnel/keyfile.ppk",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file {'awstunneld':
    ensure  => file,
    path    => "$servicepath",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => "#!/bin/bash

#export XAUTHORITY=\$HOME/.Xauthority
export DISPLAY=:0.0
export PATHTOCERT=\${HOME}'/certs'
export CERT=\${PATHTOCERT}/keyfile.ppk
export LPORT='8081'
export RPORT='22'
export REMOTEHOST='52.31.107.108'
export REMOTEUSER='ec2-user'
export PATH=\"$::path\"
export BINPATH='/usr/bin'
export PID=`lsof -nPi:\${LPORT} | grep LISTEN | head -1 | awk {'print \$2'}`

xhost +

start() {
  putty -ssh -i \${CERT} -D \${LPORT} -P \${RPORT} -l \${REMOTEUSER} \${REMOTEHOST} &
}

stop() {
  #export PID=`lsof -nPi:\${LPORT} | grep LISTEN | head -1 | awk {'print \$2'}`
  kill -9 \${PID}
}

status() {
  if [ `lsof -nPi:\${LPORT} | grep LISTEN | wc -l` -lt 2 ]; then
  #if [[ \"${PID}\" == \"\" ]]; then
    echo -e '\\nAL: Túnel AWS, puerto '\${LPORT}': CERRADO.\\n'
    start
    exit 1
  else
    #export PID=`lsof -nPi:\${LPORT} | grep LISTEN | head -1 | awk {'print \$2'}`
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
    user        => 'root',
    hour        => '*',
    minute      => '*/1',
    environment => "PATH=$::path:.",
  }
}

class {'awstunnel':}
