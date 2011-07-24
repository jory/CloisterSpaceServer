require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "non-unique email is invalid" do
    User.create(:email => "same@email.com")
    assert !User.create(:email => "same@email.com").valid?
  end

  test "authenticate" do
    User.create(:email => "found@you.com")
    assert User.authenticate("found@you.com")

    assert_nil(User.authenticate("missing@person.com"))
  end
  
  test "needs email" do
    assert !User.create().valid?
  end

  test "valid User" do
    assert User.create(:email => "some@guy.com").valid?
  end
end
