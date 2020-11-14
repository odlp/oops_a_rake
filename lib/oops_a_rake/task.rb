require_relative "registry"

module OopsARake
  module Task
    def self.included(klass)
      klass.extend(ClassMethods)
      Registry::register(klass)
    end

    def self.with_name(custom_task_name)
      module_name = "#{custom_task_name.gsub(":", "_").classify}ClassMethods"
      mod = const_set(module_name, Module.new)

      mod.define_singleton_method(:included) do |klass|
        klass.extend(OopsARake::Task::ClassMethods)
        klass.define_singleton_method(:task_name) { custom_task_name }
        Registry::register(klass)
      end

      mod
    end

    module ClassMethods
      def task_name
        name.underscore.gsub("/", ":").delete_suffix("_task")
      end

      def description(description)
        task.comment = description
      end

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
