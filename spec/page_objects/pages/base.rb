# Base page object
class Base < SitePrism::Page
  include Autospec::PageHelperModule

  def initialize
    wait_for_ajax
  end

end