require 'minitest'
require 'minites/autorun'
require 'minitest/ci'

if ENV["CIRCLECI"]
  Minitest::Ci.report_dir = "/tmp/test-results"
end

class MinitTest::Test
  # include other helpers, etc
end