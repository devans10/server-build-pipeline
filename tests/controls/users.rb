title "users profile"

control "users-1.0" do
  impact 1.0
  title "users"
  desc "Verify required users"

  describe user('devans') do
    it { should exist }
  end

  describe user('oracle') do
    it { should exist }
  end
end