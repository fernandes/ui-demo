# frozen_string_literal: true

module Docs
  # Section displaying JavaScript/Stimulus controller information
  class JavascriptSection < Phlex::HTML
    def initialize(data:)
      @data = data || {}
    end

    def view_template
      return if @data.empty?

      render Section.new(title: "JavaScript", id: "javascript") do
        render_controller_info
        render_values
        render_actions
        render_events
      end
    end

    private

    def render_controller_info
      controller = @data[:controller] || @data["controller"]
      return unless controller

      div(class: "mb-4") do
        h4(class: "text-sm font-medium mb-2") { "Stimulus Controller" }
        code(class: "px-2 py-1 bg-muted rounded text-sm font-mono") { controller }
      end
    end

    def render_values
      values = @data[:values] || @data["values"]
      return if values.nil? || values.empty?

      div(class: "mb-4") do
        h4(class: "text-sm font-medium mb-2") { "Values" }
        div(class: "rounded-lg border overflow-hidden") do
          table(class: "w-full text-sm") do
            thead(class: "bg-muted/50") do
              tr do
                th(class: "text-left p-3 font-medium") { "Name" }
                th(class: "text-left p-3 font-medium") { "Type" }
                th(class: "text-left p-3 font-medium") { "Description" }
              end
            end
            tbody do
              values.each do |value|
                tr(class: "border-t") do
                  td(class: "p-3 font-mono text-sm") { value[:name] || value["name"] }
                  td(class: "p-3 text-muted-foreground") { value[:type] || value["type"] }
                  td(class: "p-3") { value[:description] || value["description"] }
                end
              end
            end
          end
        end
      end
    end

    def render_actions
      actions = @data[:actions] || @data["actions"]
      return if actions.nil? || actions.empty?

      div(class: "mb-4") do
        h4(class: "text-sm font-medium mb-2") { "Actions" }
        div(class: "flex flex-wrap gap-2") do
          actions.each do |action|
            code(class: "px-2 py-1 bg-muted rounded text-sm font-mono") { action }
          end
        end
      end
    end

    def render_events
      events = @data[:events] || @data["events"]
      return if events.nil? || events.empty?

      div(class: "mb-4") do
        h4(class: "text-sm font-medium mb-2") { "Events" }
        div(class: "rounded-lg border overflow-hidden") do
          table(class: "w-full text-sm") do
            thead(class: "bg-muted/50") do
              tr do
                th(class: "text-left p-3 font-medium") { "Event" }
                th(class: "text-left p-3 font-medium") { "Description" }
                th(class: "text-left p-3 font-medium") { "Detail" }
              end
            end
            tbody do
              events.each do |event|
                tr(class: "border-t") do
                  td(class: "p-3 font-mono text-sm") { event[:name] || event["name"] }
                  td(class: "p-3") { event[:description] || event["description"] }
                  td(class: "p-3 font-mono text-sm text-muted-foreground") do
                    event[:detail] || event["detail"] || "-"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
