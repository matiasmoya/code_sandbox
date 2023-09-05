require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "the truth" do
    user = users(:one)
    post = Post.new title: "My Post", user: user, content: "My Content"
    assert post.save
    assert user.posts.any?
    assert user.my_posts.any?
  end
end
