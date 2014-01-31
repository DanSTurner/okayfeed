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

          describe "edit user" do
            before { click_link "Edit user" }

            it { should have_content("Twitter username") }

            describe "add twitter account" do
              before do
                # fill_in "user_email",             with: "test@test.com"
                fill_in "user_twitter_username",  with: "testtwitteruser"
                fill_in "user_current_password",  with: "password"
              end
              it "should accept a twitter username" do
                expect { click_button "Update" }.to change{ User.find_by_email("test@test.com").twitter_username }.from(nil).to("testtwitteruser")
              end
            end
          end
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