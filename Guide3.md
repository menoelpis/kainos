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