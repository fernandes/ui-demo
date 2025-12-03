# frozen_string_literal: true

module Docs
  # Section displaying accessibility information
  class AccessibilitySection < Phlex::HTML
    def initialize(data:)
      @data = data || {}
    end

    def view_template
      return if @data.empty?

      render Section.new(title: "Accessibility", id: "accessibility") do
        render_pattern_info
        render_description
        render_aria_attributes
      end
    end

    private

    def render_pattern_info
      pattern = @data[:aria_pattern] || @data["aria_pattern"]
      reference = @data[:w3c_reference] || @data["w3c_reference"]

      return unless pattern

      div(class: "flex items-center gap-2 mb-4") do
        span(class: "text-sm text-muted-foreground") { "Adheres to the" }
        a(
          href: reference,
          target: "_blank",
          rel: "noopener noreferrer",
          class: "text-sm font-medium text-primary hover:underline"
        ) { "#{pattern} WAI-ARIA design pattern" }
      end
    end

    def render_description
      description = @data[:description] || @data["description"]
      return unless description

      p(class: "text-sm text-muted-foreground mb-4") { description.strip }
    end

    def render_aria_attributes
      attributes = @data[:aria_attributes] || @data["aria_attributes"]
      return if attributes.nil? || attributes.empty?

      h4(class: "text-sm font-medium mb-2") { "ARIA Attributes" }
      ul(class: "list-disc list-inside text-sm text-muted-foreground space-y-1") do
        attributes.each do |attr|
          li { attr }
        end
      end
    end
  end
end
