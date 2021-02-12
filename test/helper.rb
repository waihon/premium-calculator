require 'minitest'
require 'minites/autorun'
require 'minitest/ci'

if ENV["CIRCLECI"]
  Minitest::Ci.report_dir = "#{ENV["CIRCLE_TEST_REPORTS"]}/reports"
end

class MinitTest::Test
  # include other helpers, etc
end