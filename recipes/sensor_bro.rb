#
# Cookbook Name:: seconion
# Recipe:: sensor_bro
#

directories = ['/opt/bro/share/bro/extractions',
               '/opt/bro/share/bro/base_streams',
               '/opt/bro/share/bro/etpro',
               '/opt/bro/share/bro/smtp-embedded-url-bloom',
               '/opt/bro/share/bro/scan_conf',
               '/opt/bro/share/bro/networks',
               '/opt/bro/share/bro/cert_authorities',
               '/opt/bro/share/bro/ja3/',
               '/opt/bro/share/bro/hassh/',
               '/opt/bro/share/bro/pcr/',
               '/opt/bro/share/bro/peers/',
               '/nsm/bro/',
               '/nsm/bro/logs',
               '/nsm/bro/extracted']


directories.each do |path|
  directory path do
    owner 'sguil'
    group 'sguil'
    mode '0755'
    action :create
  end
end


############
# Configure Bro
############

template '/opt/bro/etc/node.cfg' do
  source 'bro/node.cfg.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
  notifies :run, 'execute[deploy_bro]', :delayed
end

template '/opt/bro/etc/networks.cfg' do
  source 'bro/networks.cfg.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
  notifies :run, 'execute[deploy_bro]', :delayed
end

template '/opt/bro/share/bro/networks/__load__.bro' do
  source 'bro/networks/__load__.bro.erb'
  mode '0644'
  owner 'sguil'
  group 'sguil'
  variables(
    :sniffing_interfaces => node['seconion']['sensor']['sniffing_interfaces']
  )
end

############
# Configure Bro Continued
# Create Specific rule files for File Extraction
############

# Create files for ET Intelligence in Bro
# template '/opt/bro/share/bro/etpro/__load__.bro' do
#    source 'bro/etpro/__load__.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
# end

# template '/opt/bro/share/bro/etpro/etpro_intel.bro' do
#    source 'bro/etpro/etpro_intel.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
# end

# Installing ET intelligence in Bro
# cron 'etpro_intel' do
#   hour '1'
#   command 'wget -q https://rules.emergingthreats.net/#{oinkcode}/reputation/brorepdata.tar.gz && tar -xzf bro-repdata.tar.gz -C /opt/bro/share/bro/etpro && rm -rf bro-repdata.tar.gz > /dev/null 2>&1'
# end

# Create files for SMTP embedded Url Bloom
template '/opt/bro/share/bro/smtp-embedded-url-bloom/__load__.bro' do
   source 'bro/smtp-embedded-url-bloom/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-bloom.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro' do
   source 'bro/smtp-embedded-url-bloom/smtp-embedded-url-cluster.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/extractions/__load__.bro' do
   source 'bro/extractions/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/extractions/extractions.bro' do
   source 'bro/extractions/extractions.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

# Create files for adding certificate authorities for verifitcation
template '/opt/bro/share/bro/cert_authorities/__load__.bro' do
   source 'bro/cert_authorities/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/cert_authorities/cert_authorities.bro' do
   source 'bro/cert_authorities/cert_authorities.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

template '/opt/bro/share/bro/scan_conf/__load__.bro' do
   source 'bro/scan_conf/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

# ja3 ssl client hash/fingerprint
template '/opt/bro/share/bro/ja3/__load__.bro' do
   source 'bro/ja3/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/ja3/ja3.bro' do
   source 'bro/ja3/ja3.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

template '/opt/bro/share/bro/ja3/ja3s.bro' do
   source 'bro/ja3/ja3s.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

template '/opt/bro/share/bro/ja3/intel_ja3.bro' do
   source 'bro/ja3/intel_ja3.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

# JA3 SSH hash/fingerprint
# ja3 ssl client hash/fingerprint
template '/opt/bro/share/bro/hassh/__load__.bro' do
   source 'bro/hassh/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/hassh/hassh.bro' do
   source 'bro/hassh/hassh.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

# pcr: Producer Consumer Ratio
template '/opt/bro/share/bro/pcr/__load__.bro' do
   source 'bro/pcr/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/pcr/producer_consumer_ratio.bro' do
   source 'bro/pcr/producer_consumer_ratio.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

# peers: Peer Descriptions
template '/opt/bro/share/bro/peers/__load__.bro' do
   source 'bro/peers/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

template '/opt/bro/share/bro/peers/peers.bro' do
   source 'bro/peers/peers.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
   notifies :run, 'execute[deploy_bro]', :delayed
end

# http2
#remote_file '/tmp/nghttp2-1.32.0.tar.gz' do
#  owner 'root'
#  group 'root'
#  mode '0644'
#  source 'https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.gz'
#  not_if do ::File.exists?("/usr/local/lib/libnghttp2.a") end
#  notifies :run, 'execute[uncompress_nghttp2]', :immediately
#end

#execute 'uncompress_nghttp2' do
#  command 'tar -xzf /tmp/nghttp2-1.32.0.tar.gz -C /tmp/'
#  not_if do ::File.exists?("/usr/local/lib/libnghttp2.a") end
#  notifies :run, 'execute[install_nghttp2]', :immediately
#  action :nothing
#end

#execute 'install_nghttp2' do
#  command 'cd /tmp/nghttp2-1.32.0; ./configure; make; make install'
#  not_if do ::File.exists?("/usr/local/lib/libnghttp2.a") end
#  action :nothing
#end

#package ['build-essentials']

#remote_file '/tmp/v1.0.4.tar.gz' do
#  owner 'root'
#  group 'root'
#  mode '0644'
#  source 'https://github.com/google/brotli/archive/v1.0.4.tar.gz'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  notifies :run, 'execute[uncompress_brotli]', :immediately
#end

#execute 'uncompress_brotli' do
#  command 'tar -xzf /tmp/v1.0.4.tar.gz -C /tmp/'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  notifies :run, 'execute[install_brotli]', :immediately
#  action :nothing
#end

#execute 'install_brotli' do
#  command 'cd /tmp/brotli-1.0.4; mkdir build && cd build; ../configure-cmake; make; make test; make install'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  action :nothing
#end


#remote_file '/tmp/0.3.0.tar.gz' do
#  owner 'root'
#  group 'root'
#  mode '0644'
#  source 'https://github.com/MITRECND/bro-http2/archive/0.3.0.tar.gz'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  notifies :run, 'execute[uncompress_bro-http2]', :immediately
#end

#remote_file '/tmp/v2.5.3.tar.gz' do
#  owner 'root'
#  group 'root'
#  mode '0644'
#  source 'https://github.com/bro/bro/archive/v2.5.3.tar.gz'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  notifies :run, 'execute[uncompress_bro]', :immediately
#end

#execute 'uncompress_bro' do
#  command 'tar -xzf /tmp/v2.5.3.tar.gz -C /tmp/'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  action :nothing
#end

#execute 'uncompress_bro-http2' do
#  command 'tar -xzf /tmp/0.3.0.tar.gz -C /tmp/'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  notifies :run, 'execute[install_bro-http2]', :immediately
#  action :nothing
#end

#execute 'install_bro-http2' do
#  command 'cd /tmp/bro-http2-0.3.0; ./configure --bro-dist=/tmp/bro-2.5.3; make; make test; make install'
#  not_if do ::File.exists?("/usr/local/bin/brotli") end
#  action :nothing
#end





# template '/opt/bro/share/bro/pcr/__load__.bro' do
#    source 'bro/pcr/__load__.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
# end

# template '/opt/bro/share/bro/pcr/producer_consumer_ratio.bro' do
#    source 'bro/pcr/producer_consumer_ratio.bro.erb'
#    owner 'sguil'
#    group 'sguil'
#    mode '0644'
#    notifies :run, 'execute[deploy_bro]', :delayed
# end



if node[:seconion][:sensor][:bro][:extracted][:rotate]
  template '/etc/cron.d/bro-rotate-extracted' do
    source 'bro/cron-bro-rotate-extracted.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end
end

# Base Streams
template '/opt/bro/share/bro/base_streams/__load__.bro' do
   source 'bro/base_streams/__load__.bro.erb'
   owner 'sguil'
   group 'sguil'
   mode '0644'
end

if node[:seconion][:sensor][:bro_base_streams]
  if node[:seconion][:sensor][:bro_base_streams][:global]
    global_streams = node[:seconion][:sensor][:bro_base_streams][:global]
  else
    global_streams = {}
  end
  if node[:seconion][:sensor][:bro_base_streams][:regional]
    regional_streams = node[:seconion][:sensor][:bro_base_streams][:regional]
  else
    regional_streams = {}
  end
  if node[:seconion][:sensor][:bro_base_streams][node[:seconion][:sensor][:sensor_group]]
    sensor_group_streams = node[:seconion][:sensor][:bro_base_streams][node[:seconion][:sensor][:sensor_group]]
  else
    sensor_group_streams = {}
  end
  if node[:seconion][:sensor][:bro_base_streams][node[:fqdn]]
    host_streams = node[:seconion][:sensor][:bro_base_streams][node[:fqdn]]
  else
    host_streams = {}
  end
else
  global_streams = {}
  regional_streams = {}
  sensor_group_streams = {}
  host_streams = {}
end

template '/opt/bro/share/bro/base_streams/base_streams.bro' do
  source 'bro/base_streams/base_streams.bro.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
  variables({
    :global_streams => global_streams,
    :regional_streams => regional_streams,
    :sensor_group_streams => sensor_group_streams,
    :host_streams => host_streams
  })
  notifies :run, 'execute[deploy_bro]', :delayed
end


if node[:seconion][:sensor][:bro_sigs]
  if node[:seconion][:sensor][:bro_sigs][:global]
    global_sigs = node[:seconion][:sensor][:bro_sigs][:global]
  else
    global_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][:regional]
    regional_sigs = node[:seconion][:sensor][:bro_sigs][:regional]
  else
    regional_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][node[:seconion][:sensor][:sensor_group]]
    sensor_group_sigs = node[:seconion][:sensor][:bro_sigs][node[:seconion][:sensor][:sensor_group]]
  else
    sensor_group_sigs = {}
  end
  if node[:seconion][:sensor][:bro_sigs][node[:fqdn]]
    host_sigs = node[:seconion][:sensor][:bro_sigs][node[:fqdn]]
  else
    host_sigs = {}
  end
else
  global_sigs = {}
  regional_sigs = {}
  sensor_group_sigs = {}
  host_sigs = {}
end

if node[:seconion][:sensor][:bro_scripts]
  if node[:seconion][:sensor][:bro_scripts][:global]
    global = node[:seconion][:sensor][:bro_scripts][:global]
  else
    global = {}
  end
  if node[:seconion][:sensor][:bro_scripts][:regional]
    regional = node[:seconion][:sensor][:bro_scripts][:regional]
  else
    regional = {}
  end
  if node[:seconion][:sensor][:bro_scripts][node[:seconion][:sensor][:sensor_group]]
    sensor_group = node[:seconion][:sensor][:bro_scripts][node[:seconion][:sensor][:sensor_group]]
  else
    sensor_group = {}
  end
  if node[:seconion][:sensor][:bro_scripts][node[:fqdn]]
    host = node[:seconion][:sensor][:bro_scripts][node[:fqdn]]
  else
    host = {}
  end
else
  global = {}
  regional = {}
  sensor_group = {}
  host = {}
end

template '/opt/bro/share/bro/site/local.bro' do
  source 'bro/site/local.bro.erb'
  owner 'sguil'
  group 'sguil'
  mode '0644'
  variables({
    :global_sigs => global_sigs,
    :regional_sigs => regional_sigs,
    :sensor_group_sigs => sensor_group_sigs,
    :host_sigs => host_sigs,
    :global => global,
    :regional => regional,
    :sensor_group => sensor_group,
    :host => host,
  })
  notifies :run, 'execute[deploy_bro]', :delayed
end


##########################
# Bro Health
##########################

template '/etc/cron.d/bro-stats' do
  source '/sensor/cron_bro-stats.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


