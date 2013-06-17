module MainHelper
  # Similar to link_to_if but when passed a block behave more like the regular link_to
  def link_to_if_block(condition, name, options = {}, html_options = {}, &block)
    if condition
      link_to(name, options, html_options, &block)
    else
      capture(name, &block)
    end
  end
end
