require 'test/unit'
require 'malarkey'

class MalarkeyTest < Test::Unit::TestCase
  def test_instantiation
    ns = Malarkey.new
    refute_nil(ns)
  end
end
