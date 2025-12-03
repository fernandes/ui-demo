# frozen_string_literal: true

module Docs
  # Example component with DSL for capturing code in multiple formats.
  # Writes code once, gets both preview and source code display.
  #
  # Usage in ERB views:
  #   render Docs::Example.new(name: "Basic Select", view_context: self) do |ex|
  #     ex.erb do
  #       render "ui/select" do
  #         # ...
  #       end
  #     end
  #   end
  #
  class Example < Phlex::HTML
    def initialize(name:, description: nil, view_context: nil)
      @name = name
      @description = description
      @view_context = view_context
      @formats = {}
    end

    def view_template(&block)
      # Capture format definitions by yielding self
      yield(self) if block_given?

      div(
        id: "example-#{@name.parameterize}",
        class: "relative my-8 flex flex-col space-y-4",
        data: { controller: "code-format", example: @name.parameterize }
      ) do
        render_header
        render_tabs
      end
    end

    # DSL methods for each format - capture HTML immediately
    def erb(language: :erb, &block)
      # Find the original ERB file from the call stack
      erb_location = find_erb_caller_location

      html = capture_with_context(&block)

      @formats[:erb] = {
        source: SourceExtractor.extract_from_erb(erb_location),
        language: language,
        html: html
      }
    end

    def phlex(language: :erb, &block)
      erb_location = find_erb_caller_location

      @formats[:phlex] = {
        source: SourceExtractor.extract_from_erb(erb_location),
        language: language,
        html: capture_with_context(&block)
      }
    end

    def view_component(language: :erb, &block)
      erb_location = find_erb_caller_location

      @formats[:view_component] = {
        source: SourceExtractor.extract_from_erb(erb_location),
        language: language,
        html: capture_with_context(&block)
      }
    end

    private

    def find_erb_caller_location
      # Walk up the call stack to find the original .html.erb file
      caller_locations.find do |loc|
        loc.path&.end_with?(".html.erb")
      end
    end

    def capture_with_context(&block)
      return "" unless @view_context

      @view_context.capture(&block)
    rescue StandardError => e
      Rails.logger.warn "Failed to capture block: #{e.message}"
      ""
    end

    def render_header
      div(class: "flex flex-col space-y-1.5") do
        h3(class: "font-semibold leading-none tracking-tight text-lg") { @name }
        if @description
          p(class: "text-sm text-muted-foreground") { @description }
        end
      end
    end

    def render_tabs
      return if @formats.empty?

      # Use example-prefixed values to ensure unique IDs across multiple examples
      prefix = @name.parameterize
      default_format = "#{prefix}-#{@formats.keys.first}"

      render UI::Tabs.new(default_value: default_format) do
        render UI::TabsList.new do
          @formats.each_key do |format|
            render UI::TabsTrigger.new(value: "#{prefix}-#{format}", default_value: default_format) do
              format_label(format)
            end
          end
        end

        @formats.each do |format, data|
          render UI::TabsContent.new(value: "#{prefix}-#{format}", default_value: default_format) do
            # Preview panel
            div(class: "preview flex min-h-[350px] w-full items-center justify-center rounded-lg border bg-background p-10") do
              raw safe(data[:html].to_s) if data[:html].present?
            end

            # Code block
            render CodeBlock.new(
              code: data[:source],
              language: data[:language]
            )
          end
        end
      end
    end

    def format_label(format)
      {
        erb: "ERB",
        phlex: "Phlex",
        view_component: "ViewComponent"
      }[format] || format.to_s.titleize
    end
  end
end
