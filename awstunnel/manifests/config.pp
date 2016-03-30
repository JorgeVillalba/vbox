# Submódulo de configuraciones
class awstunnel::config {
  # Configuraciones
  file {'configuser':
    ensure => directory,
    path   => "$awstunnel::params::confuser",
    mode   => '0755',
    owner  => "$awstunnel::params::usuario",
    group  => "$awstunnel::params::grupo",
  }
  file {'bashconf':
    ensure  => file,
    path    => "$awstunnel::params::confuser/$awstunnel::params::bashconf",
    source  => "puppet:///modules/$module_name/$awstunnel::params::bashconf",
    mode    => '0664',
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
    require => File['configuser'],
  }
  file {'aptconfuser':
    ensure  => file,
    path    => "$awstunnel::params::confuser/$awstunnel::params::prxsysconf",
    source  => "puppet:///modules/$module_name/$awstunnel::params::prxsysconf",
    mode    => '0664',
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
    require => File['configuser'],
  }
  file {'basetoolscripts':
    ensure => directory,
    path   => "$awstunnel::params::basescripts",
    mode   => '0755',
    owner  => "$awstunnel::params::usuario",
    group  => "$awstunnel::params::grupo",
  }
  file {'toolscripts':
    ensure  => directory,
    path    => "$awstunnel::params::scriptspath",
    mode    => '0755',
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
    require => File['basetoolscripts'],
  }
  file {'certspath':
    ensure => directory,
    path   => "$awstunnel::params::certspath",
    mode   => '0755',
    owner  => "$awstunnel::params::usuario",
    group  => "$awstunnel::params::grupo",
  }
  file {'ppk':
    ensure  => file,
    path    => "$awstunnel::params::certspath/keyfile.ppk",
    require => File['certspath'],
    source  => "puppet:///modules/$module_name/keyfile.ppk",
    mode    => '0755',
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
  }
  file {'sitepp':
    ensure  => file,
    path    => '/etc/puppet/manifests/site.pp',
    require => Package['puppet'],
    source  => "puppet:///modules/$module_name/site.pp",
    mode    => '0664',
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
  }
  file {'etc':
    ensure  => directory,
    path    => '/etc',
    mode    => '0775',
    owner   => 'root',
    group   => "$awstunnel::params::grupo",
  }
  file {'apt':
    ensure  => directory,
    path    => "$awstunnel::params::prxsysdir",
    mode    => '0775',
    owner   => 'root',
    group   => "$awstunnel::params::grupo",
    require => File['etc'],
  }
  file {'aptconf':
    ensure  => file,
    path    => "$awstunnel::params::prxsysdir/$awstunnel::params::prxsysconf",
    mode    => '0664',
    owner   => 'root',
    group   => "$awstunnel::params::grupo",
    require => File['apt'],
  }
  file {'awstunneld':
    ensure  => file,
    path    => "$awstunnel::params::servicepath",
    owner   => "$awstunnel::params::usuario",
    group   => "$awstunnel::params::grupo",
    mode    => '0755',
    content => "#!/bin/bash

export USER=\"$awstunnel::params::usuario\"
export HOME=`grep \${USER} /etc/passwd | awk -F: {'print \$6'}`
export DISPLAY=:0.0
export PATHTOCERT=\${HOME}'/certs'
export CERT=\${PATHTOCERT}/keyfile.ppk
export LPORT='8081'
export LHOST='127.0.0.1'
export RPORT='22'
export REMOTEHOST='52.31.107.108'
export REMOTEUSER='ec2-user'
export PATH=\"$::path\"
#export BINPATH='/usr/bin'
export CONFDIR=$awstunnel::params::confuser
export PRXSYSDIR=$awstunnel::params::prxsysdir
export PRXSYSCONF=\${PRXSYSDIR}/$awstunnel::params::prxsysconf
export PID=`sudo -u root lsof -nPi:\${LPORT} | grep LISTEN | head -1 | awk {'print \$2'}`

xhost +

start() {
  sudo -u root putty -ssh -i \${CERT} -D \${LPORT} -P \${RPORT} -l \${REMOTEUSER} \${REMOTEHOST} &
  if [ ! -d \${PRXSYSDIR} ]; then
    sudo -u root mkdir \${PRXSYSDIR}
    sudo -u root chmod 777 \${PRXSYSDIR}
  fi
  sudo -u root echo 'Acquire::Socks::Proxy \"socks://'\${LHOST}':'\${LPORT}'/\";' > \${PRXSYSCONF}
  echo 'export SOCKS_PROXY=\"socks://'\${LHOST}':'\${LPORT}'\";' >> \${HOME}/.bashrc
  echo 'export SOCKS_PROXY=\"socks://'\${LHOST}':'\${LPORT}'\";' >> \${HOME}/.bash_profile
  gsettings set org.gnome.system.proxy use-same-proxy false
  gsettings set org.gnome.system.proxy.http enabled true
  gsettings set org.gnome.system.proxy.http host \"''\"
  gsettings set org.gnome.system.proxy.http port \"0\"
  gsettings set org.gnome.system.proxy.https host \"''\"
  gsettings set org.gnome.system.proxy.https port \"0\"
  gsettings set org.gnome.system.proxy.socks host \"'\${LHOST}'\"
  gsettings set org.gnome.system.proxy.socks port \"\${LPORT}\"
  gsettings set org.gnome.system.proxy.ftp host \"''\"
  gsettings set org.gnome.system.proxy.ftp port \"0\"

}

stop() {
  sudo -u root kill -9 \${PID}
  if [ -f \${PRXSYSCONF} ]; then
    sudo -u root echo \"\" > \${PRXSYSCONF}
  fi
  if [[ -f \$HOME/.bash_profile ]]; then
    sed -i '/proxy|PROXY|Proxy/d' ~/.bash_profile
  fi
  if [[ -f \$HOME/.bashrc ]]; then
    sed -i '/proxy|PROXY|Proxy/d' ~/.bashrc
  fi
  gsettings set org.gnome.system.proxy mode 'none'
  gsettings set org.gnome.system.proxy.http use-authentication false
  gsettings set org.gnome.system.proxy.http authentication-user \"''\"
  gsettings set org.gnome.system.proxy.http authentication-password \"''\"

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
