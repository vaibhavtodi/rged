require File.dirname(__FILE__) + '/../test_helper'
require 'country_controller'

# Re-raise errors caught by the controller.
class CountryController; def rescue_action(e) raise e end; end

class CountryControllerTest < Test::Unit::TestCase
  def setup
    @controller = CountryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
