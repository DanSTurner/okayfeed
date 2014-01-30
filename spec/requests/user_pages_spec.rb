require 'spec_helper'

describe "UserPages" do
  subject { page }

  before { visit root_url }

  describe "signup" do
    before { click_link 'Sign Up' }

    let(:submit) { "Sign up" }

    it { should have_title "New user sign up" }

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

      describe "after sign up" do
        before { click_button submit }
        it { should have_content("Sign out") }

        describe "visit user page" do
          before do
            click_link "Profile"
          end
          it { should have_content "test@test.com" }
        end

        describe "after signing out" do
          before { click_link "Sign out" }
          it { should have_content("Sign in") }

          describe "and then signing in" do
            before do
              click_link "Sign in"
              fill_in "user_email",    with: "test@test.com"
              fill_in "user_password", with: "password"
              click_button "Sign in"
            end

            it { should have_content("Sign out") }
          end
        end
      end
    end
  end
end