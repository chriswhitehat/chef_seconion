#
# Cookbook Name:: seconion
# Recipe:: sensor_bpf
#

node[:seconion][:sensor][:sniffing_interfaces].each do |sniff|


  filters = {
    :global => {},
    :regional => {},
    :sensor_group => {},
    :host => {},
    :sensor => {}
    }

  if node[:seconion][:sensor][:bpf]

    scopes = ['global',  
              'regional', 
              node[:seconion][:sensor][:sensor_group], 
              node[:fqdn],
              sniff[:sensorname] ]

    scopes.each do |scope|
      if node[:seconion][:sensor][:bpf][scope]
        node[:seconion][:sensor][:bpf][scope].each do | fitler, enabled |
          if enabled
            bpf << filter
          end
        end
      end
    end
  end

  template "/etc/nsm/#{sniff[:sensorname]}/bpf.conf" do
    source "sensor/bpf.conf.erb"
    owner 'sguil'
    group 'sguil'
    mode '0644'
    variables({
      :sniff => sniff,
      :bpf => bpf.join(' && ')
    })
  end

  ['bpf-bro', 'bpf-ids', 'bpf-pcap'].each do | bpf_file |
    link "/etc/nsm/#{sniff[:sensorname]}/#{bpf_file}.conf" do
      to "/etc/nsm/#{sniff[:sensorname]}/bpf.conf"
    end
  end
end

