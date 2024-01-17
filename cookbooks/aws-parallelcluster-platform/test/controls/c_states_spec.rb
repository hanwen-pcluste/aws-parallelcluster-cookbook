control 'tag:config_c_states_disabled' do
  only_if { os_properties.x86? && !os_properties.on_docker? }

  describe bash("cat /sys/module/intel_idle/parameters/max_cstate") do
    its('stdout') { should cmp 1 }
  end
end
