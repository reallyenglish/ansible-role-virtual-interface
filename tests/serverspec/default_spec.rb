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
else
  raise "unsupported OS #{ os[:family] }"
end
