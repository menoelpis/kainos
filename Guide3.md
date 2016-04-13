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
