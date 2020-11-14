# OOP(s) a Rake

Write your Rake tasks as plain-old Ruby objects.

## Setup

Add the gem to your Gemfile and `bundle install`:

```ruby
gem "oops_a_rake"
```

In your Rakefile, require `oops_a_rake` and require your tasks:

```ruby
# Rakefile

require "oops_a_rake"

Dir.glob("lib/tasks/*.rb").each { |task| require_relative(task) }
```

## Usage

### Simple task with a description

Write a class which:

- responds to `#call`
- includes `OopsARake::Task`

```ruby
class GreetingTask
  include OopsARake::Task

  description "An enthusiastic greeting"

  def call
    puts "Hello!"
  end
end
```

When you list all the Rake tasks in the project:

```sh
$ bundle exec rake --tasks
```

You should see the `greeting` task listed (note the optional 'task' suffix from
the class name is omitted):

```
rake greeting   # An enthusiastic greeting
```

N.B. Unless you include a `description` for a task then Rake won't list it by
default. Run `bundle exec rake --tasks --all` to see tasks without descriptions.

### Task with arguments

**Note:** Only positional arguments are supported.

```ruby
class PersonalizedGreetingTask
  include OopsARake::Task

  def call(name)
    puts "Hello #{name}!"
  end
end
```

Invocation:

```sh
bundle exec rake "personalized_greeting[Bob]"
# => Hello Bob!
```

### Task with prequisites

```ruby
class ComplexSetupTask
  include OopsARake::Task

  prerequisites :task_one, :task_two

  def call
    # Your implementation
  end
end
```

### Namespaced task

```ruby
class Admin::SpecialTask
  include OopsARake::Task

  def call
    # Your implementation
  end
end
```

Invocation:

```sh
bundle exec rake admin:special
```

### Task with a custom name

```ruby
class ObscureClassNameTask do
  include OopsARake::Task.with_name("custom_name")

  def call
    puts "Hello"
  end
end
```

Invocation:

```sh
bundle exec rake custom_name
```

## Motivation

Rake is an omnipresent tool in the Ruby world. It has some drawbacks – the main
issue I've heard repeatedly is how difficult it is to test Rake tasks.

Testing Rake tasks isn't impossible, but it's complex and requires some
familiarity with how Rake works (see [Test Rake Tasks Like a BOSS][testing-tasks]
for an excellent guide).

As a result I've seen many codebases which opt for writing thin Rake tasks that
call a plain Ruby object, which is tested in isolation:

```ruby
task :greeting do |_, args|
  SomeObject.new(*args).call
end
```

Instead of writing this glue-code by hand it's cleaner to write your tasks as
objects:

```ruby
# lib/tasks/greeting_task.rb

class GreetingTask
  include OopsARake::Task

  def call(name)
    puts "Hello #{name}"
  end
end
```

To test this task you can then initialize a new instance and invoke `#call`.
This side-steps any requirement to manage Rake's world in tests. For example in
RSpec:


```ruby
require "tasks/greeting_task"

RSpec.describe GreetingTask do
  it "personalizes the greeting" do
    task = described_class.new
    task.call("Bob")

    # ... rest of your test
  end
end
```

This approach is heavily inspired by Sidekiq, which allows jobs to be tested the
same way:

```ruby
class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    # do something
  end
end
```

[testing-tasks]: https://thoughtbot.com/blog/test-rake-tasks-like-a-boss
