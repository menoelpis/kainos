================================================
Rspec Test Environment Setup
================================================

[Gemfile]

group :development, :test do 
	gem "rspec-rails", '~> 3.0' 
end

$ bundle install

$ bundle exec rails g rspec:install

[spec/spec_helper.rb]

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = [:expect]
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

[spec/dummy_spec.rb]

require "rails_helper.rb"

describe "testing that rspec is configured" do
	it "should pass" do 
		expect(true).to eq(true)
	end
	it "can fail" do 
		expect(false).to eq(true)
	end
end

$ bundle exec rake

[spec/models/user_spec.rb]

require 'rails_helper'

describe User do  
	describe "email" do
		let(:user) {
			User.create!(email: "foo@example.com",
						 password: "qwertyuiop",
						 password_confirmation: "qwertyuiop")
		}
		it "absolutely prevents invalid email addresses" do 
			expect {
				user.update_attribute(:email, "foo@bar.com")
			}.to raise_error(ActiveRecord::StatementInvalid,
							 /email_must_be_company_email/i)
		end
	end
end

$ rspec spec/models/user_spec.rb

[spec/support/violate_check_constraint_matcher.rb]

RSpec::Matchers.define :violate_check_constraint do |constraint_name|
	supports_block_expectations
	match do |code_to_test|
		begin
			code_to_test.()
			false
		rescue ActiveRecord::StatementInvalid => ex 
			ex.message =~ /#{constraint_name}/
		end
	end
end

[spec/models/user_spec.rb]

+ require 'support/violate_check_constraint_matcher'

$ rspec spec/models/user_spec.rb

================================================
PhantomJS Installation
================================================

$ sudo apt-get update
$ sudo apt-get install build-essential chrpath libssl-dev libxft-dev
$ sudo apt-get install libfreetype6 libfreetype6-dev
$ sudo apt-get install libfontconfig1 libfontconfig1-dev

$ cd ~
$ export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
$ wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
$ sudo tar xvjf $PHANTOM_JS.tar.bz2

$ sudo mv $PHANTOM_JS /usr/local/share
$ sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

$ phantomjs --version

$ phantomjs 
phantomjs> console.log("HELLO!"); 
HELLO! 
undefined 
phantomjs>

================================================
Poltergeist & Database Cleaner Setup
================================================

[Gemfile]

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails',    '3.4.2'
+ gem 'poltergeist'
+ gem 'database_cleaner'
end

[spec/rails_helper.rb]

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
  require 'spec_helper'
  require 'rspec/rails'
+ require 'capybara/poltergeist'
+ Capybara.javascript_driver = :poltergeist
+ Capybara.default_driver    = :poltergeist

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
   config.fixture_path = "#{::Rails.root}/spec/fixtures"

 + config.use_transactional_fixtures = false
 + config.infer_spec_type_from_file_location!



 + config.before(:each, :type => :feature) do
 +   DatabaseCleaner.strategy = :truncation
 + end
 
end

[spec/features/angular_test_app_spec.rb]

require 'rails_helper'

feature "angular test" do

	let(:email)    { "bob@example.com" } 
	let(:password) { "password123" }

	before do 
		User.create!(email: email, 
					 password: password, 
					 password_confirmation: password) 
	end

	scenario "Our Angular Test App is Working" do 
		visit "/angular_test"
		# Log In 
		fill_in "Email", with: "bob@example.com" 
		fill_in "Password", with: "password123" 
		click_button "Log in"

		# Check that we go to the right page 
		expect(page).to have_content("Name")

		# Test the page 
		fill_in "name", with: "Bob" 
		within "header h1" do 
			expect(page).to have_content("Hello, Bob") 
		end 
	end

end

$ rspec spec/features/angular_test_app_spec.rb 