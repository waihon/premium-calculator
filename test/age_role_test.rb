module AgeRoleTest
  def test_plays_age_role
    assert_respond_to @role_player, :age
  end
end
