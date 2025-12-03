# frozen_string_literal: true

module Docs
  # Extracts source code from ERB templates using caller_locations.
  # This enables the DRY pattern where code is written once and
  # automatically displayed as both preview and source code.
  class SourceExtractor
    # Extract from a caller location pointing to an ERB file
    def self.extract_from_erb(caller_location)
      return "" unless caller_location

      file = caller_location.path
      line = caller_location.lineno

      return "" unless file && line && File.exist?(file)

      new(file, line).extract_erb_block
    end

    def initialize(file, line)
      @file = file
      @line = line
    end

    def extract_erb_block
      lines = File.readlines(@file)
      start_idx = @line - 1

      return "" if start_idx >= lines.length

      opening_line = lines[start_idx]

      # Check if caller_location points to the DSL method call (example.erb do)
      # or to the first line of content inside the block
      if opening_line.match?(/example\.(erb|phlex|view_component)\s+do/)
        # Skip the DSL method line, extract content inside
        extract_erb_do_block(lines, start_idx)
      elsif opening_line.include?(" do ")
        # Already pointing to content (first line inside block)
        # Find the end and include this line
        extract_erb_do_block_inclusive(lines, start_idx)
      elsif start_idx > 0 && lines[start_idx - 1].match?(/example\.(erb|phlex|view_component)\s+do/)
        # Caller points to content, but previous line is the DSL method
        # Use the DSL line as the starting point
        extract_erb_do_block(lines, start_idx - 1)
      else
        extract_by_indentation(lines, start_idx)
      end
    end

    private

    def extract_erb_do_block(lines, start_idx)
      # Find the end of this block by tracking ERB block depth
      end_idx = start_idx + 1
      depth = 1

      while end_idx < lines.length && depth > 0
        line = lines[end_idx]

        # Count ERB block openers: <% ... do %>, <% ... do |...| %>
        depth += count_erb_openers(line)
        # Count ERB block closers: <% end %>
        depth -= count_erb_closers(line)

        end_idx += 1
      end

      # Extract content between opening and closing lines
      # Skip the opening line (example.erb do) and the closing line (<% end %>)
      extract_content(lines, start_idx + 1, end_idx - 1)
    end

    def extract_erb_do_block_inclusive(lines, start_idx)
      # The start_idx is already pointing to content (first line inside block)
      # Include this line and find the matching end
      end_idx = start_idx
      depth = 1 # Start with 1 because opening line has `do`

      while end_idx < lines.length && depth > 0
        line = lines[end_idx]

        depth += count_erb_openers(line)
        depth -= count_erb_closers(line)

        end_idx += 1
      end

      # Include start_idx, exclude the final <% end %>
      extract_content(lines, start_idx, end_idx - 1)
    end

    def extract_by_indentation(lines, start_idx)
      base_indent = lines[start_idx][/^\s*/].length
      end_idx = start_idx + 1

      while end_idx < lines.length
        line = lines[end_idx]
        current_indent = line[/^\s*/].length

        # Empty lines are okay
        break if !line.strip.empty? && current_indent <= base_indent

        end_idx += 1
      end

      extract_content(lines, start_idx + 1, end_idx)
    end

    def extract_content(lines, start_idx, end_idx)
      content = lines[start_idx...end_idx]
      return "" if content.nil? || content.empty?

      # Calculate minimum indentation (ignoring empty lines)
      min_indent = content
        .reject { |l| l.strip.empty? }
        .map { |l| l[/^\s*/].length }
        .min || 0

      # Dedent all lines
      result = content.map { |l|
        if l.strip.empty?
          ""
        elsif l.length > min_indent
          l[min_indent..].rstrip
        else
          l.rstrip
        end
      }.join("\n").strip

      # Clean up ERB output tags for display
      clean_erb_for_display(result)
    end

    def count_erb_openers(line)
      # Match patterns like: <% ... do %> or <% ... do |...| %>
      # Also match <% if/unless/case/while/until/for/begin/class/module/def
      count = 0

      # Block-starting keywords with do
      count += 1 if line.match?(/<%=?\s*.*\s+do\s*(\|[^|]*\|)?\s*%>/)

      # Control flow that opens blocks (without do)
      count += 1 if line.match?(/<%\s*(if|unless|case|while|until|for|begin)\b/)

      count
    end

    def count_erb_closers(line)
      # Match <% end %>
      line.scan(/<%\s*end\s*%>/).length
    end

    def clean_erb_for_display(code)
      # Remove wrapping ERB tags from the content for cleaner display
      # Keep the core render calls visible
      code
    end
  end
end
