#
# Helpers for zone file template
#

module Named
  module ZoneHelpers
    def zone_record(record)
      record = {
        name: '@',
        proto: 'IN',
        type: 'A',
        prio: '',
      }.merge(record)

      "%-20s %5s %8s %5s %5s %s" % [
        record[:name],
        record[:ttl],
        record[:proto],
        record[:type],
        record[:prio],
        record[:data]
      ]
    end
  end
end
