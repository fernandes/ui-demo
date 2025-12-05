module ApplicationHelper
  # Sub-component suffixes to filter out from the sidebar
  SUB_COMPONENT_SUFFIXES = %w[
    content trigger item label group slot button badge skeleton
    header footer title description close overlay portal
    scrollbar thumb corner viewport panel handle inset rail
    provider sub separator checkbox radio shortcut icon
    indicator action media error legend addon body caption
    cell head row wrapper menu
  ].freeze

  # Components that should NOT be filtered out even if they match sub-component pattern
  EXCEPTION_SLUGS = %w[
    button_group
    toggle_group
    input_group
  ].freeze

  def components_for_sidebar
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

  private

  def sub_component?(slug, all_slugs)
    return false if slug.nil?
    return false unless slug.include?("_")
    return false if EXCEPTION_SLUGS.include?(slug)

    parts = slug.split("_")
    return false if parts.length < 2

    suffix = parts.last
    return false unless SUB_COMPONENT_SUFFIXES.include?(suffix)

    # Check if parent component exists
    (1...parts.length).any? do |i|
      parent_slug = parts[0...i].join("_")
      all_slugs.include?(parent_slug)
    end
  end
end
