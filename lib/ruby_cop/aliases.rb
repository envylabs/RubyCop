module RubyCop
  # Some aliases to smooth over some issues with the two different forks of the
  # library. This is temporary until all apps using the library have been
  # updated to use the non-Analyzer version.
  module Analyzer
    GrayList = ::RubyCop::GrayList
    NodeBuilder = ::RubyCop::NodeBuilder
    Policy = ::RubyCop::Policy
    Ruby = ::RubyCop::Ruby
  end
end
