# frozen_string_literal: true

require 'active_support/core_ext/time'
require 'fugit'

module CronZoneConverter
  class Converter
    def initialize(line, local_zone = nil, remote_zone = nil)
      @base = build_base line
      @local_zone = build_local_zone local_zone
      @remote_zone = build_remote_zone remote_zone
      @offset = build_offset
      @crons  = []
    end

    def convert
      return [base.original] unless needs_changes?

      split_base
      apply_offset
      merge_similar
      final_lines
    end

    private

    attr_reader :base, :local_zone, :remote_zone, :offset, :crons

    def build_base(line)
      ::Fugit::Cron.new(line).tap { |x| raise Error, 'invalid cron line' if x.nil? }
    rescue StandardError => e
      raise Error.new('invalid cron line', e)
    end

    def build_local_zone(value)
      return value if value.is_a?(ActiveSupport::TimeZone)

      build_string_zone(value) || build_other_zone
    end

    def build_remote_zone(value)
      return value if value.is_a?(ActiveSupport::TimeZone)

      build_string_zone(value) || Time.find_zone('UTC')
    end

    def build_string_zone(value)
      return false unless value.is_a? String

      ::Time.find_zone(value).tap { |x| raise Error, 'invalid zone' if x.nil? }
    end

    def build_other_zone
      return ::Time.find_zone(base.timezone.name) if base.timezone
      return Time.zone if Time.zone

      raise Error, 'missing zone'
    end

    def build_offset
      # local_zone.now.utc_offset.to_f / 3600
      (local_zone.now.utc_offset.to_f - remote_zone.now.utc_offset.to_f) / 3600
    end

    def needs_changes?
      return false if local_zone.name == remote_zone.name
      return false if base.hours.nil?
      return false if base.original.split(' ')[1] =~ %r{^\*/\d{1,2}$}

      true
    end

    def split_base
      @crons = base.hours.map { |x| Duplicator.change base, hour: x }
      @crons = base.monthdays.map { |x| crons.map { |y| Duplicator.change y, dom: x } }.flatten unless base.monthdays.nil?
      @crons = base.weekdays.map { |x| crons.map { |y| Duplicator.change y, dow: x } }.flatten unless base.weekdays.nil?
    end

    def apply_offset
      @crons.map! do |cron|
        day_diff = nil
        hour = (cron.hours.first - offset).to_i

        if hour < 0
          day_diff = -1
          hour     = 24 + hour
        elsif hour > 23
          day_diff = 1
          hour -= 24
        end

        Duplicator.change cron, hour: hour, day_diff: day_diff
      end
    end

    def merge_similar
      @crons = Merger.merge crons
    end

    def final_lines
      @crons.map(&:to_cron_s)
    end
  end
end
