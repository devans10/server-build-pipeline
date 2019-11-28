title "Installed Packages"

control "packages-1.0" do
  impact 1.0
  title "packages"
  desc "Verify required packagess"

  describe package('openscap-scanner') do
    it { should be_installed }
  end

  describe package('wget') do
    it { should be_installed }
  end

end