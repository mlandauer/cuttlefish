# frozen_string_literal: true

# Adapted from https://github.com/yrgoldteeth/bootstrap-will_paginate/blob/master/config/initializers/will_paginate.rb

class BootstrapLinkRenderer < WillPaginate::ActionView::LinkRenderer
  def html_container(html)
    tag :div, tag(:ul, html), container_attributes
  end

  def page_number(page)
    tag :li,
        link(page, page, rel: rel_value(page)),
        class: ("active" if page == current_page)
  end

  def gap
    tag :li,
        link("&hellip;".html_safe, "#"),
        class: "disabled"
  end

  def previous_or_next_page(page, text, classname)
    tag :li,
        link(text, page || "#"),
        class: [
          (classname.split("_").first if @options[:page_links]),
          ("disabled" unless page)
        ].join(" ")
  end
end
