class awstunnel {
  include awstunnel::install
  include awstunnel::config
  include awstunnel::service
  Class[Awstunnel::Install] ->
  Class[Awstunnel::Config]  ->
  Class[Awstunnel::Service]
}

class {'awstunnel':}
