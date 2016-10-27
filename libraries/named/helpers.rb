#
# A few helpers ;)
#

module Named
  module Helpers
    def generate_zone_serial(dt=DateTime.now)
      # dt.strftime('%Y%m%d%H%M%S')
      Time.now.to_i.to_s
    end
  end
end
