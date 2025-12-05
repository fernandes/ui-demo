# frozen_string_literal: true

class ComponentsController < ApplicationController
  before_action :load_sidebar_components

  def index
    @components = load_components
  end

  def show
    @component_name = params[:slug]
  end

  private

  def load_components
    components_path = UI::Engine.root.join("docs", "components")
    return [] unless File.directory?(components_path)

    Dir[File.join(components_path, "*.yml")].map do |path|
      data = YAML.load_file(path, symbolize_names: true)
      {
        name: data[:name],
        slug: data[:slug],
        category: data[:category],
        description: data[:description]&.lines&.first&.strip
      }
    end.sort_by { |c| c[:name] }
  rescue StandardError => e
    Rails.logger.warn "Failed to load components: #{e.message}"
    []
  end
end
