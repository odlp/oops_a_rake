require "rake"
require "active_support/core_ext/string"

module OopsARake
  class Registry
    @tasks = {}

    def self.register(task_class)
      task_name = task_class.name.underscore.gsub("/", ":").delete_suffix("_task")

      task = Rake::Task.define_task(task_name) do |_, args|
        task_class.new.call(*args)
      end

      @tasks[task_class] = task
      task
    end

    def self.fetch(task_class)
      @tasks.fetch(task_class)
    end
  end
end
