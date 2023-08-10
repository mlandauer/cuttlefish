# frozen_string_literal: true

class PagerRenderer < WillPaginate::ActionView::LinkRenderer
  def to_html
    tag(:ul, previous_page + next_page, class: "pager")
  end

  def previous_page
    num = @collection.current_page > 1 && (@collection.current_page - 1)
    previous_or_next_page(num, @options[:previous_label], "previous")
  end

  def next_page
    num = @collection.current_page < total_pages && (@collection.current_page + 1)
    previous_or_next_page(num, @options[:next_label], "next")
  end

  def previous_or_next_page(page, text, classname)
    text += tag(:span, @options[:text]).html_safe if classname == "previous"
    if page
      tag(:li, link(text, page), class: classname)
    else
      tag(:li, tag(:a, text, href: "#"), class: "#{classname} disabled")
    end
  end
end
