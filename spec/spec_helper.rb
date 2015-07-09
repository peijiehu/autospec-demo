require 'capybara'
require 'capybara/rspec'
require 'site_prism'
require 'autospec'

require 'page_objects/all_page_objects'

Capybara.run_server = false

# set default js enabled driver based on user input(env variable),
# which applies to all tests marked with :type => :feature
# default is :selenium, and selenium uses :firefox by default
driver_helper = Autospec::DriverHelper.new("#{Dir.pwd}/config/autospec/saucelabs.yml")
driver_to_use = driver_helper.driver
Capybara.javascript_driver = driver_to_use.to_sym

# sets app_host based on user input(env variable)
app_host = ENV['r_env'] || begin
  Autospec.logger.debug "r_env is not set, using default env 'qa'"
  'qa'
end
env_yaml = YAML.load_file("#{Dir.pwd}/config/autospec/env.yml")
Capybara.app_host = env_yaml[app_host]

RSpec.configure do |config|

  config.before :each do |example|
    example_full_description = example.full_description
    begin
      driver_helper.set_sauce_session_name(example_full_description) if driver_to_use.include?('saucelabs') && !driver_to_use.nil?
      Autospec.logger.debug "Finished setting saucelabs session name for #{example_full_description}"
    rescue
      Autospec.logger.debug "Failed setting saucelabs session name for #{example_full_description}"
    end
    page.driver.allow_url '*' if driver_to_use == 'webkit'
  end
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end
