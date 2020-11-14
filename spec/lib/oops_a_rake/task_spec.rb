require "oops_a_rake/task"

RSpec.describe OopsARake::Task do
  let(:rake) { Rake::Application.new }
  before(:each) { Rake.application = rake }

  it "defines a Rake task which can be invoked" do
    define_class("GreetingTask") do
      include OopsARake::Task

      def call
        puts "Hello"
      end
    end

    expect { Rake::Task["greeting"].invoke }.to output(/Hello/).to_stdout
  end

  it "defines the task name on the class" do
    define_class("GreetingTask") do
      include OopsARake::Task

      def call
      end
    end

    expect(GreetingTask.task_name).to eq("greeting")
  end

  it "supports tasks with arguments" do
    define_class("PersonalizedGreetingTask") do
      include OopsARake::Task

      def call(name)
        puts "Hello #{name}"
      end
    end

    expect { Rake::Task["personalized_greeting"].invoke("Bob") }
      .to output(/Hello Bob/).to_stdout
  end

  it "supports configuring prerequsite Rake tasks" do
    define_class("TaskOne") do
      include OopsARake::Task

      def call
        puts self.class.name
      end
    end

    define_class("TaskTwo") do
      include OopsARake::Task

      def call
        puts self.class.name
      end
    end

    define_class("TaskThree") do
      include OopsARake::Task

      prerequisites :task_one, :task_two

      def call
        puts self.class.name
      end
    end

    task = Rake::Task["task_three"]

    expect(task.prerequisites).to eq([:task_one, :task_two])
    expect { task.invoke }.to output(
      <<~TXT
        TaskOne
        TaskTwo
        TaskThree
      TXT
    ).to_stdout
  end

  it "allows tasks to be described" do
    define_class("WellDocumentedTask") do
      include OopsARake::Task

      description "Informative"

      def call
      end
    end

    expect(Rake::Task["well_documented"].comment).to eq("Informative")
  end

  describe "custom task name" do
    it "allows tasks to specify a custom name" do
      define_class("ObscureClassNameTask") do
        include OopsARake::Task.with_name("clear_name")

        def call
          puts "Hello"
        end
      end

      expect { Rake::Task["clear_name"].invoke }.to output(/Hello/).to_stdout
      expect(Rake::Task.task_defined?("obscure_class_name")).to be false
    end

    it "provides access to the task name from the class" do
      define_class("ObscureClassNameTask") do
        include OopsARake::Task.with_name("custom_name")

        def call
        end
      end

      expect(ObscureClassNameTask.task_name).to eq("custom_name")
    end

    it "names the module" do
      define_class("ObscureClassNameTask") do
        include OopsARake::Task.with_name("foo:bar_baz")

        def call
        end
      end

      expect(ObscureClassNameTask.included_modules.map(&:to_s))
        .to include("OopsARake::Task::FooBarBazClassMethods")
    end
  end

  private

  def define_class(name, &block)
    const = stub_const(name, Class.new)
    const.class_eval(&block) if block_given?
    const
  end
end
