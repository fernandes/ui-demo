# frozen_string_literal: true

module Docs
  # Table displaying keyboard shortcuts
  class KeyboardTable < Phlex::HTML
    def initialize(shortcuts:)
      @shortcuts = shortcuts || []
    end

    def view_template
      return if @shortcuts.empty?

      render Section.new(title: "Keyboard Shortcuts", id: "keyboard") do
        div(class: "rounded-lg border overflow-hidden") do
          table(class: "w-full text-sm") do
            thead(class: "bg-muted/50") do
              tr do
                th(class: "text-left p-3 font-medium w-1/3") { "Key" }
                th(class: "text-left p-3 font-medium") { "Description" }
              end
            end
            tbody do
              @shortcuts.each do |shortcut|
                tr(class: "border-t") do
                  td(class: "p-3") do
                    render_kbd(shortcut[:key] || shortcut["key"])
                  end
                  td(class: "p-3") { shortcut[:description] || shortcut["description"] }
                end
              end
            end
          end
        end
      end
    end

    private

    def render_kbd(key)
      span(
        class: "inline-flex items-center justify-center px-2 py-1 " \
               "text-xs font-mono bg-muted rounded border min-w-[2rem]"
      ) { key }
    end
  end
end
