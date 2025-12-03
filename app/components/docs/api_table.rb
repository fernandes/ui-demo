# frozen_string_literal: true

module Docs
  # Table displaying component API parameters
  class ApiTable < Phlex::HTML
    def initialize(name:, description: nil, parameters: [], data_attributes: [], css_variables: [])
      @name = name
      @description = description
      @parameters = parameters || []
      @data_attributes = data_attributes || []
      @css_variables = css_variables || []
    end

    def view_template
      div(class: "mb-8") do
        render_header
        render_parameters if @parameters.any?
        render_data_attributes if @data_attributes.any?
        render_css_variables if @css_variables.any?
      end
    end

    private

    def render_header
      h3(class: "font-semibold text-lg mb-2") { @name }
      if @description
        p(class: "text-sm text-muted-foreground mb-4") { @description }
      end
    end

    def render_parameters
      h4(class: "text-sm font-medium text-muted-foreground mb-2") { "Parameters" }
      div(class: "rounded-lg border overflow-hidden mb-4") do
        table(class: "w-full text-sm") do
          thead(class: "bg-muted/50") do
            tr do
              th(class: "text-left p-3 font-medium") { "Name" }
              th(class: "text-left p-3 font-medium") { "Type" }
              th(class: "text-left p-3 font-medium") { "Default" }
              th(class: "text-left p-3 font-medium") { "Description" }
            end
          end
          tbody do
            @parameters.each do |param|
              tr(class: "border-t") do
                td(class: "p-3 font-mono text-sm") { param[:name] || param["name"] }
                td(class: "p-3 text-muted-foreground") { param[:type] || param["type"] }
                td(class: "p-3 font-mono text-sm") { param[:default] || param["default"] || "-" }
                td(class: "p-3") { param[:description] || param["description"] }
              end
            end
          end
        end
      end
    end

    def render_data_attributes
      h4(class: "text-sm font-medium text-muted-foreground mb-2") { "Data Attributes" }
      div(class: "rounded-lg border overflow-hidden mb-4") do
        table(class: "w-full text-sm") do
          thead(class: "bg-muted/50") do
            tr do
              th(class: "text-left p-3 font-medium") { "Attribute" }
              th(class: "text-left p-3 font-medium") { "Values" }
              th(class: "text-left p-3 font-medium") { "Description" }
            end
          end
          tbody do
            @data_attributes.each do |attr|
              tr(class: "border-t") do
                td(class: "p-3 font-mono text-sm") { attr[:name] || attr["name"] }
                td(class: "p-3 font-mono text-sm") do
                  values = attr[:values] || attr["values"] || []
                  values.join(", ")
                end
                td(class: "p-3") { attr[:description] || attr["description"] }
              end
            end
          end
        end
      end
    end

    def render_css_variables
      return if @css_variables.empty?

      h4(class: "text-sm font-medium text-muted-foreground mb-2") { "CSS Variables" }
      div(class: "rounded-lg border overflow-hidden") do
        table(class: "w-full text-sm") do
          thead(class: "bg-muted/50") do
            tr do
              th(class: "text-left p-3 font-medium") { "Variable" }
              th(class: "text-left p-3 font-medium") { "Description" }
            end
          end
          tbody do
            @css_variables.each do |var|
              tr(class: "border-t") do
                td(class: "p-3 font-mono text-sm") { var[:name] || var["name"] }
                td(class: "p-3") { var[:description] || var["description"] }
              end
            end
          end
        end
      end
    end
  end
end
