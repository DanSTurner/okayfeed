require 'spec_helper'

describe "UserPages" do
  subject { page }

  before { visit root_url }

  describe "signup" do
    before { click_link 'Sign Up' }

    let(:submit) { "Sign up" }

    it { should have_title "Sign Up for OkayFeed" }

    describe "with invalid information" do
      it "should not add a user account" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid info" do
      before do
        fill_in "user_email",                 with: "test@test.com"
        fill_in "user_password",              with: "password"
        fill_in "user_password_confirmation", with: "password"
      end

      it "should add a user account" do
        expect { click_button submit }.to change(User, :count)
      end
    end
  end
end