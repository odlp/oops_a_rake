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

  private

  def define_class(name, &block)
    const = stub_const(name, Class.new)
    const.class_eval(&block) if block_given?
    const
  end
end
