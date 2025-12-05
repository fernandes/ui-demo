# frozen_string_literal: true

module Docs
  # Left sidebar navigation component for documentation pages.
  # Similar to shadcn/ui docs sidebar structure.
  # Used across all docs pages (installation, components, etc.)
  class Sidebar < Phlex::HTML
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::Routes

    def initialize(current_slug: nil, current_path: nil)
      @current_slug = current_slug
      @current_path = current_path
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
      render_section_group("Components", helpers.components_for_sidebar)
    end

    def render_section_group(title, items)
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
  end
end
