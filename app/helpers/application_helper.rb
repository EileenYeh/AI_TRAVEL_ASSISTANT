# app/helpers/application_helper.rb
module ApplicationHelper
  def render_markdown(text)
    return '' if text.blank?

    # 使用Redcarpet处理Markdown
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,
        safe_links_only: true,
        hard_wrap: true,
        link_attributes: { target: '_blank' }
      ),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true
    )

    markdown.render(text).html_safe
  end
end
