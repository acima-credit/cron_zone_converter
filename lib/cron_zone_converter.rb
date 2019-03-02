# frozen_string_literal: true

require 'active_support/core_ext/time'
require 'fugit'

require 'cron_zone_converter/version'
require 'cron_zone_converter/error'
require 'cron_zone_converter/duplicator'
require 'cron_zone_converter/merger'
require 'cron_zone_converter/converter'

module CronZoneConverter
  def self.convert(line, local_zone = nil, remote_zone = nil)
    Converter.new(line, local_zone, remote_zone).convert
  end
end
