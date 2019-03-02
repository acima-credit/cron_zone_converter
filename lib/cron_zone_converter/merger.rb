# frozen_string_literal: true

module CronZoneConverter
  class Merger
    class << self
      def merge(crons)
        return crons unless crons.size > 1

        merge_by_hour(merge_by_dow(merge_by_dom(crons))).sort{ |a, b| a.to_cron_s <=> b.to_cron_s }
      end

      private

      def merge_by_hour(ary)
        ary.each_with_object({}) do |cron, merged|
          marker         = cron_marker cron, :hour
          merged[marker] = if merged.key?(marker)
                             Duplicator.change merged[marker], add_hour: cron.hours.first
                           else
                             cron
                           end
        end.values
      end

      def merge_by_dom(ary)
        ary.each_with_object({}) do |cron, merged|
          marker         = cron_marker cron, :dom
          merged[marker] = if merged.key?(marker)
                             Duplicator.change merged[marker], add_dom: cron.monthdays.first
                           else
                             cron
                           end
        end.values
      end

      def merge_by_dow(ary)
        ary.each_with_object({}) do |cron, merged|
          marker         = cron_marker cron, :dow
          merged[marker] = if merged.key?(marker)
                             Duplicator.change merged[marker], add_dow: cron.weekdays.first.first
                           else
                             cron
                           end
        end.values
      end

      def cron_marker(cron, exclude_key)
        keys  = %i[minute hour dom month dow]
        marks = []
        cron.to_cron_s.split(' ').each_with_index do |x, i|
          next if keys[i] == exclude_key

          marks << x
        end
        marks.join(' ')
      end
    end
  end
end
