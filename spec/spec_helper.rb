# frozen_string_literal: true

require 'bundler/setup'
require 'cron_zone_converter'
require 'timecop'

RSpec.configure do |config|
  config.filter_run focus: true if ENV['FOCUS'].to_s == 'true'
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:each, utc: true) do
    Time.zone = 'UTC'
  end
  config.before(:each, mst: true) do
    Time.zone = 'America/Denver'
    Timecop.freeze Time.new(2019, 3, 8, 12, 0, 0)
  end
  config.before(:each, mdt: true) do
    Time.zone = 'America/Denver'
    Timecop.freeze Time.new(2019, 3, 12, 12, 0, 0)
  end
  config.before(:each, han: true) do
    Time.zone = 'Hanoi'
    Timecop.freeze Time.new(2019, 3, 12, 12, 0, 0)
  end
  config.before(:each, est: true) do
    Time.zone = 'EST'
    Timecop.freeze Time.new(2019, 3, 8, 12, 0, 0)
  end
  config.before(:each, none: true) do
    Time.zone = nil
  end

  config.after(:each) do
    Time.zone = nil
    Timecop.return
  end
end
