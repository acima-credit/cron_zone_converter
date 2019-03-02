# frozen_string_literal: true

module CronZoneConverter
  class Duplicator
    def self.change(base, changes = {})
      new(base, changes).change
    end

    def initialize(base, changes = {})
      @base    = ::Fugit::Cron.new base
      @changes = changes
      @parts   = @base.to_h
    end

    def change
      return base.dup if changes.empty?

      update_hours
      update_weekdays
      update_monthdays

      ::Fugit::Cron.new line
    end

    private

    attr_reader :base, :parts, :changes

    def update_hours
      parts[:hours] = [changes[:hour]] if changes[:hour]
      parts[:hours] = changes[:hours] if changes[:hours]
      parts[:hours] = parts[:hours] + [changes[:add_hour]] if changes[:add_hour]
    end

    def update_weekdays
      parts[:weekdays] = [[changes[:dow]]] if changes[:dow]
      parts[:weekdays] = parts[:weekdays] + [[changes[:add_dow]]] if changes[:add_dow]
      return unless changes[:day_diff]

      parts[:weekdays]&.map! do |x|
        v = x.first + changes[:day_diff]
        v -= 6 if v > 6
        v = 6 + v if v < 0
        [v]
      end
    end

    def update_monthdays
      parts[:monthdays] = [[changes[:dom]]] if changes[:dom]
      parts[:monthdays] = (parts[:monthdays] || []) + [changes[:add_dom]] if changes[:add_dom]
      return unless changes[:day_diff]

      parts[:monthdays]&.map! do |x|
        v = x + changes[:day_diff]
        raise Error, 'cannot change month' if v < 0

        v = 31 if v > 31
        v
      end
    end

    def line
      [
        parts[:seconds] == [0] ? nil : (parts[:seconds] || ['*']).join(','),
        (parts[:minutes] || ['*']).join(','),
        (parts[:hours] || ['*']).join(','),
        (parts[:monthdays] || ['*']).join(','),
        (parts[:months] || ['*']).join(','),
        (parts[:weekdays] || [['*']]).map { |d| d.compact.join('#') }.join(','),
        base.zone
      ].compact.join(' ')
    end
  end
end
