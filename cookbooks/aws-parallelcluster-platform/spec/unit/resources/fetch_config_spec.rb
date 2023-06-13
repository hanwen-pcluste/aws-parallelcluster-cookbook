require 'spec_helper'

describe 'fetch_config:run' do
  context "when running from kitchen" do
    cached(:cluster_config_path) { 'cluster_config_path' }
    cached(:instance_types_data_path) { 'instance_types_data_path' }
    cached(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu', step_into: %w(fetch_config)
      ) do |node|
        node.override['kitchen'] = true
        node.override['cluster']['cluster_config_path'] = cluster_config_path
        node.override['cluster']['instance_types_data_path'] = instance_types_data_path
      end
      runner.converge_dsl do
        fetch_config 'run' do
          action :run
        end
      end
    end

    it "copies data from kitchen data dir" do
      is_expected.to create_remote_file("copy fake cluster config")
        .with(path: cluster_config_path)
        .with(source: "file://#{kitchen_cluster_config_path}")

      is_expected.to create_remote_file("copy fake instance type data")
        .with(path: instance_types_data_path)
        .with(source: "file://#{kitchen_instance_types_data_path}")
    end
  end
end