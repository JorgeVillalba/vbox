class awstunnel {
  include awstunnel::params
  include awstunnel::install
  include awstunnel::config
  include awstunnel::service
  Class[Awstunnel::Params]  ->
  Class[Awstunnel::Install] ->
  Class[Awstunnel::Config]  ->
  Class[Awstunnel::Service]
}

class {'awstunnel':}
