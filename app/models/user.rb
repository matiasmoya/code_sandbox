require "#{Rails.root}/tmp/models/concerns/user_override.rb"

class User < ApplicationRecord
  include UserOverride
end
