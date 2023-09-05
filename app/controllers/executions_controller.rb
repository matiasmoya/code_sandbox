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

    File.open("#{Rails.root}/tmp/models/concerns/user_override.rb", "w") do |f|
      f.write(model_content)
    end

    results = `cd #{Rails.root} && rails test test/models`
    
    render json: { results: results }
  end
end
