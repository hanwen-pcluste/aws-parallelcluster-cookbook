# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster
# Recipe:: efs
#
# Copyright:: 2013-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

case node['platform']
when 'amazon'
  package 'amazon-efs-utils'
when 'centos'
  bash "install efs utils" do
    cwd node['cluster']['sources_dir']
    code <<-EFSUTILSINSTALL
      set -e
      git clone https://github.com/aws/efs-utils
      cd efs-utils
      make rpm
      yum -y install ./build/amazon-efs-utils*rpm
    EFSUTILSINSTALL
  end
when 'ubuntu'
  bash "install efs utils" do
    cwd node['cluster']['sources_dir']
    code <<-EFSUTILSINSTALL
      set -e
      git clone https://github.com/aws/efs-utils
      cd efs-utils
      ./build-deb.sh
      apt-get -y install ./build/amazon-efs-utils*deb
    EFSUTILSINSTALL
  end
end
