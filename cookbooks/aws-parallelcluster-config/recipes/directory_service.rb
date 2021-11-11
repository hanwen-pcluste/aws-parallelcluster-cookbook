# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster
# Recipe:: directory_service
#
# Copyright:: 2013-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

return if node['cluster']["directory_service"]["enabled"] == 'false'

package %w(sssd sssd-tools sssd-ldap curl python-sss) do
  retries 10
  retry_delay 5
end

directory_service_dir = "#{node['cluster']['shared_dir']}/directory_service"
ldap_default_authtok_path = "#{directory_service_dir}/ldap_default_authtok_path"

if node['cluster']['node_type'] == 'HeadNode'
  # Head node contacts the secret manager to retrieve the password and share the obfuscated string to compute nodes.
  # Only contacting the secret manager from head node avoids giving permission to compute nodes to contact the secret manager.

  directory directory_service_dir do
    owner 'root'
    group 'root'
    mode '0600'
    recursive true
  end

  template '/tmp/get_obfuscated_password.sh' do
    source 'directory_service/get_obfuscated_password.sh.erb'
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
  end

  file ldap_default_authtok_path do
    content lazy { shell_out!("sh /tmp/get_obfuscated_password.sh").stdout }
    owner 'root'
    group 'root'
    mode '0600'
    sensitive true
  end
end

template '/etc/sssd/sssd.conf' do
  source 'directory_service/sssd.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(obfuscated_password: lazy { shell_out!("cat #{ldap_default_authtok_path}").stdout })
  sensitive true
end

bash 'Configure Directory Service' do
  user 'root'
  # Tell NSS, PAM to use SSSD for system authentication and identity information
  # Modify SSHD config to enable password login
  # Restart modified services
  code <<-AD
      authconfig --enablemkhomedir --enablesssdauth --enablesssd --updateall
      sed -ri 's/\s*PasswordAuthentication\s+no$/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      for SERVICE in sssd sshd; do
      systemctl restart $SERVICE
      done
  AD
  sensitive true
end
