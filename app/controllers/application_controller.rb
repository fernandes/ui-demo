class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def load_sidebar_components
    @sidebar_components = load_components_list
  end

  def load_components_list
    components_path = UI::Engine.root.join("docs", "components")
    return [] unless File.directory?(components_path)

    Dir[File.join(components_path, "*.yml")].map do |path|
      data = YAML.load_file(path, symbolize_names: true)
      {
        name: data[:name],
        slug: data[:slug],
        category: data[:category]
      }
    end.sort_by { |c| c[:name] }
  rescue StandardError => e
    Rails.logger.warn "Failed to load components: #{e.message}"
    []
  end
end
