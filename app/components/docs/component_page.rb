# frozen_string_literal: true

module Docs
  # Main documentation page component that orchestrates all sections.
  # Loads metadata from YAML and renders the complete component documentation.
  #
  # Usage:
  #   render Docs::ComponentPage.new(component_name: "select") do
  #     render Docs::Example.new(name: "Basic") do |ex|
  #       ex.erb { ... }
  #     end
  #   end
  #
  class ComponentPage < Phlex::HTML
    def initialize(component_name:)
      @component_name = component_name
      @metadata = load_metadata(component_name)
    end

    def view_template(&examples_block)
      # Outer wrapper - centralized layout for all component pages
      div(class: "flex-1 items-start") do
        div(class: "flex-1 md:grid md:grid-cols-[220px_minmax(0,1fr)] md:gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-10") do
        # Left sidebar with navigation
        render Sidebar.new(current_slug: @component_name)

        # Main content area with optional right TOC (shadcn structure)
        div(class: "flex items-stretch xl:w-full") do
          # Main content column
          div(class: "flex min-w-0 flex-1 flex-col") do
            # Content wrapper - centered with max-w-2xl like shadcn
            div(class: "mx-auto flex w-full max-w-2xl min-w-0 flex-1 flex-col gap-8 px-4 py-6 md:px-0 lg:py-8") do
              render_header
              render_description

              # Examples section - yields to the block with examples
              if block_given?
                render Section.new(title: "Examples", id: "examples") do
                  yield
                end
              end

              render_features
              render_api
              render_common_ratios
              render AccessibilitySection.new(data: @metadata[:accessibility] || @metadata["accessibility"])
              render KeyboardTable.new(shortcuts: @metadata[:keyboard] || @metadata["keyboard"])
              render JavascriptSection.new(data: @metadata[:javascript] || @metadata["javascript"])
            end
          end

          # Right sidebar TOC
          render Toc.new(metadata: @metadata)
        end
        end
      end
    end

    private

    def load_metadata(name)
      yaml_path = UI::Engine.root.join("docs", "components", "#{name}.yml")
      return {} unless File.exist?(yaml_path)

      YAML.load_file(yaml_path, symbolize_names: true)
    rescue StandardError => e
      Rails.logger.warn "Failed to load component metadata: #{e.message}"
      {}
    end

    def render_header
      div(class: "space-y-2") do
        h1(class: "scroll-m-20 text-4xl font-bold tracking-tight") do
          @metadata[:name] || @metadata["name"] || @component_name.titleize
        end
      end
    end

    def render_description
      description = @metadata[:description] || @metadata["description"]
      return unless description

      p(class: "text-lg text-muted-foreground -mt-4") do
        description.lines.first&.strip
      end
    end

    def render_features
      features = @metadata[:features] || @metadata["features"]
      return if features.nil? || features.empty?

      render Section.new(title: "Features", id: "features") do
        ul(class: "my-6 ml-6 list-disc [&>li]:mt-2") do
          features.each do |feature|
            li { feature }
          end
        end
      end
    end

    def render_api
      api = @metadata[:api] || @metadata["api"]
      return if api.nil? || api.empty?

      render Section.new(title: "API Reference", id: "api") do
        api.each do |component_name, details|
          details = details.transform_keys(&:to_sym) if details.is_a?(Hash)
          render ApiTable.new(
            name: component_name.to_s,
            description: details[:description],
            parameters: details[:parameters],
            data_attributes: details[:data_attributes],
            css_variables: details[:css_variables]
          )
        end
      end
    end

    def render_common_ratios
      ratios = @metadata[:common_ratios] || @metadata["common_ratios"]
      return if ratios.nil? || ratios.empty?

      render Section.new(title: "Common Ratios Reference", id: "common-ratios") do
        div(class: "overflow-x-auto") do
          table(class: "w-full text-sm") do
            thead do
              tr(class: "border-b") do
                th(class: "text-left p-2 font-medium") { "Ratio" }
                th(class: "text-left p-2 font-medium") { "Calculation" }
                th(class: "text-left p-2 font-medium") { "Use Case" }
              end
            end
            tbody do
              ratios.each do |ratio_data|
                ratio_data = ratio_data.transform_keys(&:to_sym) if ratio_data.is_a?(Hash)
                tr(class: "border-b") do
                  td(class: "p-2") { ratio_data[:ratio] }
                  td(class: "p-2 font-mono text-sm") { ratio_data[:calculation] }
                  td(class: "p-2 text-muted-foreground") { ratio_data[:use_case] }
                end
              end
            end
          end
        end
      end
    end
  end
end
