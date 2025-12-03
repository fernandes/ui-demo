# frozen_string_literal: true

module Docs
  # Code block with syntax highlighting and copy button.
  # Uses Rouge for syntax highlighting when available.
  class CodeBlock < Phlex::HTML
    def initialize(code:, language: "ruby")
      @code = code
      @language = language
    end

    def view_template
      div(class: "relative group") do
        render_copy_button
        render_code
      end
    end

    private

    def render_copy_button
      button(
        type: "button",
        class: "absolute right-3 top-3 z-10 opacity-0 group-hover:opacity-100 " \
               "transition-opacity p-2 rounded-md hover:bg-muted",
        data: {
          controller: "clipboard",
          action: "click->clipboard#copy",
          clipboard_content_value: @code
        },
        aria: { label: "Copy code" }
      ) do
        # Copy icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "16",
          height: "16",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: "text-muted-foreground",
          data: { clipboard_target: "icon" }
        ) do |s|
          s.rect(width: "14", height: "14", x: "8", y: "8", rx: "2", ry: "2")
          s.path(d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2")
        end
        span(class: "sr-only") { "Copy code" }
      end
    end

    def render_code
      pre(class: "overflow-x-auto rounded-lg border bg-muted/50 p-4 text-sm") do
        code(class: "font-mono highlight") do
          if syntax_highlighting_available?
            raw safe(highlight_code(@code, @language))
          else
            plain @code
          end
        end
      end
    end

    def syntax_highlighting_available?
      defined?(Rouge)
    end

    def highlight_code(code, language)
      formatter = Rouge::Formatters::HTML.new
      lexer = find_lexer(language)
      formatter.format(lexer.lex(code))
    rescue StandardError
      ERB::Util.html_escape(code)
    end

    def find_lexer(language)
      case language.to_s
      when "erb", "html+erb"
        Rouge::Lexers::ERB.new
      when "ruby", "rb"
        Rouge::Lexers::Ruby.new
      when "css"
        Rouge::Lexers::CSS.new
      else
        Rouge::Lexer.find(language) || Rouge::Lexers::PlainText.new
      end
    end
  end
end
