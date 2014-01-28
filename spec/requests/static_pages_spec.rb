require 'spec_helper'

describe "StaticPages" do
  subject { page }

  before { visit root_url }

  it { should have_title "OkayFeed" }
  it { should have_content "OkayFeed" }
  it { should have_link "Sign Up" }

end
