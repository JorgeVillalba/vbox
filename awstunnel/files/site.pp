node /^*virtualbox/ {
  include awstunnel
  include ::awstunnel::install
  include ::awstunnel::config
  include ::awstunnel::service
  notify{"Mi $::hostname de $::operatingsystem: Hemos incluído todos los módulos para $::fqdn": }
}
node default {
	notify{"The default puppet configuration": }
}

#node 'jorge-virtualbox.homestation' {
#  include awstunnel
#  include ::awstunnel::install
#  include ::awstunnel::config
#  include ::awstunnel::service
#  notify{"Nodo jorge-virtualbox": }
#}
