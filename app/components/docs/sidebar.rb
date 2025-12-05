# frozen_string_literal: true

module Docs
  # Left sidebar navigation component for documentation pages.
  # Similar to shadcn/ui docs sidebar structure.
  # Used across all docs pages (installation, components, etc.)
  class Sidebar < Phlex::HTML
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::Routes

    # Sub-component suffixes to filter out from the sidebar
    # These are components that are part of a parent component
    # Only filter if the prefix (before underscore) is also a component
    SUB_COMPONENT_SUFFIXES = %w[
      content trigger item label group slot button badge skeleton
      header footer title description close overlay portal
      scrollbar thumb corner viewport panel handle inset rail
      provider sub separator checkbox radio shortcut icon
      indicator action media error legend addon body caption
      cell head row wrapper menu
    ].freeze

    # Components that should NOT be filtered out even if they match sub-component pattern
    # These are standalone components that happen to have a suffix matching a parent
    EXCEPTION_SLUGS = %w[
      button_group
      toggle_group
      input_group
    ].freeze

    def initialize(current_slug: nil, current_path: nil)
      @current_slug = current_slug
      @current_path = current_path
      @components = load_components
    end

    def view_template
      aside(class: "hidden lg:block") do
        # Sticky container - stays fixed below header
        # Uses --header-height CSS variable for precise positioning
        div(class: "sticky top-[--header-height] z-30 h-[calc(100vh-var(--header-height))]") do
          # Scrollable content area - independent scroll from main
          # py-6 lg:py-8 matches content area padding for alignment
          div(class: "flex h-full flex-col gap-2 overflow-y-auto overflow-x-hidden py-6 lg:py-8 scrollbar-none") do
            render_get_started_section
            render_components
          end
        end
      end
    end

    private

    def render_get_started_section
      div(class: "relative flex w-full min-w-0 flex-col") do
        div(class: "flex h-8 shrink-0 items-center text-xs font-medium text-muted-foreground") do
          "Get Started"
        end
        ul(class: "flex w-full min-w-0 flex-col gap-0.5") do
          render_nav_link("Installation", helpers.docs_installation_path)
        end
      end
    end

    def render_components
      render_section_group("Components", @components, is_components: true)
    end

    def render_section_group(title, items, is_components: false)
      div(class: "relative flex w-full min-w-0 flex-col pt-4") do
        div(class: "flex h-8 shrink-0 items-center text-xs font-medium text-muted-foreground") do
          title
        end
        ul(class: "flex w-full min-w-0 flex-col gap-0.5") do
          items.each do |item|
            render_component_link(item)
          end
        end
      end
    end

    def render_nav_link(name, path)
      is_current = @current_path == path

      li(class: "group/menu-item relative") do
        a(
          href: path,
          class: link_classes(is_current),
          data: { active: is_current }
        ) { name }
      end
    end

    def render_component_link(component)
      is_current = component[:slug] == @current_slug

      li(class: "group/menu-item relative") do
        a(
          href: component_path(slug: component[:slug]),
          class: link_classes(is_current),
          data: { active: is_current }
        ) { component[:name] }
      end
    end

    def link_classes(is_active)
      base = "flex items-center gap-2 rounded-md px-2 py-1.5 text-left text-sm font-medium hover:bg-accent hover:text-accent-foreground"

      if is_active
        "#{base} bg-accent text-accent-foreground"
      else
        "#{base} text-foreground"
      end
    end

    def load_components
      components_path = UI::Engine.root.join("docs", "components")
      return [] unless File.directory?(components_path)

      # First pass: collect all component slugs to know what exists
      all_slugs = Dir[File.join(components_path, "*.yml")].map do |path|
        YAML.load_file(path, symbolize_names: true)[:slug]
      end.compact.to_set

      # Second pass: filter out sub-components
      Dir[File.join(components_path, "*.yml")].filter_map do |path|
        data = YAML.load_file(path, symbolize_names: true)
        slug = data[:slug]

        # Skip sub-components
        next if sub_component?(slug, all_slugs)

        {
          name: data[:name],
          slug: slug
        }
      end.sort_by { |c| c[:name] }
    rescue StandardError => e
      Rails.logger.warn "Failed to load components: #{e.message}"
      []
    end

    def sub_component?(slug, all_slugs)
      return false if slug.nil?
      return false unless slug.include?("_")
      return false if EXCEPTION_SLUGS.include?(slug)

      # Check if this looks like a sub-component by seeing if:
      # 1. It ends with a known sub-component suffix
      # 2. AND the prefix (parent) exists as a separate component
      parts = slug.split("_")
      return false if parts.length < 2

      suffix = parts.last
      return false unless SUB_COMPONENT_SUFFIXES.include?(suffix)

      # Check if parent component exists
      # For "select_item" -> check if "select" exists
      # For "sidebar_menu_button" -> check if "sidebar_menu" or "sidebar" exists
      (1...parts.length).any? do |i|
        parent_slug = parts[0...i].join("_")
        all_slugs.include?(parent_slug)
      end
    end
  end
end
