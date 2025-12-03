# frozen_string_literal: true

module Docs
  # Table of contents sidebar with links to page sections
  class Toc < Phlex::HTML
    # Map section IDs to their metadata keys
    SECTION_METADATA_MAP = {
      "features" => :features,
      "api" => :api,
      "common-ratios" => :common_ratios,
      "accessibility" => :accessibility,
      "keyboard" => :keyboard,
      "javascript" => :javascript
    }.freeze

    ALL_SECTIONS = [
      { id: "examples", title: "Examples", scan_examples: true },
      { id: "features", title: "Features" },
      { id: "api", title: "API Reference" },
      { id: "common-ratios", title: "Common Ratios" },
      { id: "accessibility", title: "Accessibility" },
      { id: "keyboard", title: "Keyboard Shortcuts" },
      { id: "javascript", title: "JavaScript" }
    ].freeze

    def initialize(metadata: {})
      @metadata = metadata || {}
      @sections = filter_sections
    end

    private

    def filter_sections
      ALL_SECTIONS.select do |section|
        metadata_key = SECTION_METADATA_MAP[section[:id]]
        # Always show examples, filter others based on metadata
        next true if metadata_key.nil?

        value = @metadata[metadata_key] || @metadata[metadata_key.to_s]
        value.present?
      end
    end

    public

    def view_template
      # Outer container - matches shadcn structure
      aside(
        class: "sticky top-14 z-30 ml-auto hidden h-[calc(100svh-3.5rem)] w-72 flex-col gap-4 overflow-hidden overscroll-none pb-8 xl:flex",
        data: { controller: "toc" }
      ) do
        # Scrollable inner container
        div(class: "scrollbar-none overflow-y-auto px-8") do
          div(class: "flex flex-col gap-2 p-4 pt-0 text-sm") do
            # Sticky title
            p(class: "text-muted-foreground bg-background sticky top-0 h-6 text-xs") do
              "On This Page"
            end

            # Links
            @sections.each do |section|
              a(
                href: "##{section[:id]}",
                class: "text-muted-foreground hover:text-foreground data-[active=true]:text-foreground text-[0.8rem] no-underline transition-colors",
                data: { active: false, toc_target: "link" }
              ) { section[:title] }

              # Container for dynamically inserted example links
              if section[:scan_examples]
                div(
                  class: "flex flex-col gap-1 pl-3",
                  data: { toc_target: "examplesContainer" }
                )
              end
            end
          end
          # Bottom spacer
          div(class: "h-12")
        end
      end
    end
  end
end
