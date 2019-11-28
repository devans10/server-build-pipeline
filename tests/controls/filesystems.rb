# encoding: utf-8

title "Filesystems profile"

control "filesystems-1.0" do
  impact 1.0
  title "Filesystems"
  desc "Verify required filesystems"

  describe directory('/data') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0700' }
  end
end
