require 'time'

module VKAudite
  module TimeHelper
    HOUR    = 1000 * 60 * 60
    MINUTE  = 1000 * 60
    SECONDS = 1000

    def self.duration(milliseconds)
      parts = [
        milliseconds / HOUR,
        milliseconds / MINUTE % 60,
        milliseconds / SECONDS % 60,
      ]

      parts.shift if parts.first.zero?

      # TODO: make readable
      [ parts.first, *parts[1..-1].map { |part| '%02d' % part }].join('.')
    end
  end
end
