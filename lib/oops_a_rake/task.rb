require_relative "registry"

module OopsARake
  module Task
    def self.included(klass)
      Registry::register(klass)
    end
  end
end
