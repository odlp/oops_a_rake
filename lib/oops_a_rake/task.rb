require_relative "registry"

module OopsARake
  module Task
    def self.included(klass)
      Registry::register(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def prerequisites(*args)
        task.enhance(args)
      end

      alias_method :prerequisite, :prerequisites

      private

      def task
        ::OopsARake::Registry.fetch(self)
      end
    end
  end
end
