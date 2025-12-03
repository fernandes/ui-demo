# frozen_string_literal: true

module Docs
  # Generic section wrapper with title and anchor link
  class Section < Phlex::HTML
    def initialize(title:, id: nil, description: nil)
      @title = title
      @id = id || title.parameterize
      @description = description
    end

    def view_template(&block)
      section(id: @id, class: "scroll-mt-20") do
        h2(class: "font-semibold text-2xl tracking-tight border-b pb-2 mb-4") do
          a(href: "##{@id}", class: "hover:underline") { @title }
        end
        if @description
          p(class: "text-muted-foreground text-sm mb-4") { @description }
        end
        yield if block_given?
      end
    end
  end
end
