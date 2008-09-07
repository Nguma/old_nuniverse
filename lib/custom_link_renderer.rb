class CustomLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

protected
  def page_link(page, text, attributes = {})
    @template.content_tag(:li, @template.link_to(text, url_for(page)), attributes)
  end
end