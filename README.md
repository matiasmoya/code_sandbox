# Interactive tests for learning rails

I wanted to code a similar experience like codecademy.com but for a ruby on rails course. Today while taking a shower I had this small idea to implement an interactive editor for a learning platform that is able to evaluate the code and give some feedback to the student.

> **TLDR**: Deploy a RoR app to aws-lambda using Lamby and override the content of some files using the request params. The file will be included as concerns in models/controllers, so we can evaluate it and return the output.

### What I wanted:
Something simple but in browser (I want to delay setting up a development environment until later in the course.)

Imagine that I want to explain how to use basic associations in rails. I want to give the student the opportunity to write some associations by himself and see how it goes.

For example, I want him to write "has_many :posts" and test that the code works with it.

### Possible solutions
- Compare the input with possible solutions (not flexible if I want to give the student the freedom to come up with some method definitions in some scenarios)
- Use a sandbox environment to run the whole application and override some files with the user input and then deliver the output.
I wanted to explore the later, and I learned about judge0 and saw a few examples, but I quickly decided that maybe something like Docker may be easier.

While reading about how people used [docker for code sandboxes experiences](https://github.com/Narasimha1997/gopg), and after reading about [how to implement firecracker to handle](https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second/) something like this too, I figured that maybe just using aws lambda may be a good quick solution for this. So here is the idea:

### The solution and what this repo tests
So, AWS Lambda uses firecracker and seems to be isolated enough that for this usecase it may be ok.
In short, the idea is to use aws lambda functions to run a ruby-on-rails app, and allow the user input to override the definition in some model or controller concerns. After that In the same controller for the aws-lambda-function I can return the output.

```ruby
# test/controllers/executions_controller_test.rb
class ExecutionsControllerTest < ActionDispatch::IntegrationTest
  test "creates a code execution and returns the output without errors for a correct answer" do
    post executions_url, params: { content: "has_many :posts"}
    assert_response :success
    assert response.body.include?("0 failures, 0 errors")
  end
end
```

```ruby
# app/controllers/executions_controller.rb
class ExecutionsController < ApplicationController
  def create
    model_content = %(
      module UserOverride
        extend ActiveSupport::Concern
       
        included do
          #{params[:content]}
        end
       
        def my_posts
          posts.pluck :title
        end
      end      
    )

    File.open("#{Rails.root}/tmp/models/user_override.rb", "w") do |f|
      f.write(model_content)
    end

    results = `cd #{Rails.root} && rails test test/models`
    
    render json: { results: results }
  end
end
```

In aws lambda we need to write the content in the tmp/ folder, since its the only place where we can actually write data once the function is running.

```ruby
# app/models/user.rb
require "#{Rails.root}/tmp/models/concerns/user_override.rb"

class User < ApplicationRecord
  include UserOverride
end
```
We require the file and include the concern here.
Is important in this step that the file includes at least the module name definition, otherwise it will throw an uninitialized constant error because the UserOverride module has not been defined anywhere. So we need the file to contain this at minimum:
```ruby
# tmp/models/concerns/user_override.rb
module  UserOverride
end
```

This weekend I'll deploy a proof of concept using lamby, and I'll write more about it on my blog.
If you have some suggestions, please open a issue! I will be very grateful 🙏
