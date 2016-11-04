require 'spec_helper'
require 'serverspec'


case os[:family]
when 'openbsd'

  describe file('/etc/hostname.gre0') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 640 }
    its(:content) { should match Regexp.escape('!echo Starting \${if}') }
    its(:content) { should match /description "GRE tunnel"\nup/ }
  end
  describe command('ifconfig gre0') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /description: GRE tunnel/ }
    its(:stderr) { should eq '' }
  end

  # Destroy
  describe file('/etc/hostname.gre1') do
    it { should_not exist }
    it { should_not be_file }
  end

  describe command("ifconfig gre1") do
    its(:exit_status) { should_not eq 0 }
    its(:stderr) { should match(/^gre1: no such interface$/) }
  end

when 'freebsd'

  describe file('/etc/rc.conf') do
    it { should be_file }
    its(:content) { should match(/#{ Regexp.escape('cloned_interfaces="${cloned_interfaces} gre0"') }/) }
    its(:content) { should match(/#{ Regexp.escape('ifconfig_gre0="inet 10.0.2.15 10.0.2.100 tunnel 192.168.1.100 192.168.2.100 grekey MY_GRE_KEY"') }/) }
  end

  describe command("ifconfig gre0") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^gre0: flags=\d+<UP,POINTOPOINT,RUNNING,MULTICAST> metric 0 mtu \d+$/) }
    its(:stdout) { should match(/^\s+tunnel inet #{ Regexp.escape('192.168.1.100') } --> #{ Regexp.escape('192.168.2.100') }$/) }
    its(:stdout) { should match(/^\s+inet #{ Regexp.escape('10.0.2.15') } --> #{ Regexp.escape('10.0.2.100') } netmask 0x0/) }
    its(:stderr) { should match(/^$/) }
  end

  # Destroy
  describe command("ifconfig gre1") do
    its(:exit_status) { should_not eq 0 }
    its(:stderr) { should match(/^ifconfig: interface gre1 does not exist$/) }
  end
  describe file('/etc/rc.conf') do
    it { should be_file }
    its(:content) { should_not match(/#{ Regexp.escape('cloned_interfaces="${cloned_interfaces} gre1"') }/) }
    its(:content) { should_not match(/ifconfig_gre1=.*/) }
  end

when 'ubuntu', 'redhat'

  case os[:family]
  when 'ubuntu'
    describe file('/etc/network/interfaces.d/tun0') do
      it { should be_file }
      its(:content) { should match(/^auto tun0$/) }
      its(:content) { should match(/^iface tun0 inet static$/) }
    end
  when 'redhat'
    describe file("/etc/sysconfig/network-scripts/ifcfg-tun0") do
      it { should be_file }
      its(:content) { should match(/^DEVICE=tun0$/) }
      its(:content) { should match(/^TYPE=GRE$/) }
    end
  end

  describe command('ip link show tun0') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should match(/^$/) }
  end

  describe command('ip addr show tun0') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should match(/^$/) }
    its(:stdout) { should match(/^\d+:\s+tun0@NONE: <POINTOPOINT,(?:MULTICAST,)?NOARP,UP,LOWER_UP> mtu \d+ qdisc noqueue state UNKNOWN.*$/i) }
    its(:stdout) { should match(/^\s+#{ Regexp.escape("link/gre 10.0.2.15 peer 10.0.2.100") }/) }
    its(:stdout) { should match(/^\s+inet #{ Regexp.escape("192.168.100.1") } peer #{ Regexp.escape("192.168.100.2/32") } (?:brd #{ Regexp.escape("192.168.100.3") } )?scope global tun0/) }
  end

else
  raise "unsupported OS #{ os[:family] }"
end
