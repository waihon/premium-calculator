module RateRoleTest
  def test_plays_rate_role
    assert_respond_to @role_player, :rate
  end
end
