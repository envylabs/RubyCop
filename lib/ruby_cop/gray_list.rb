require 'set'

module RubyCop
  # Combination blacklist and whitelist.
  class GrayList
    def initialize
      @blacklist = Set.new
      @whitelist = Set.new
    end

    # An item is allowed if it's whitelisted, or if it's not blacklisted.
    def allow?(item)
      @whitelist.include?(item) || !@blacklist.include?(item)
    end

    def blacklist(item)
      @whitelist.delete(item)
      @blacklist.add(item)
    end

    def whitelist(item)
      @blacklist.delete(item)
      @whitelist.add(item)
    end
  end
end