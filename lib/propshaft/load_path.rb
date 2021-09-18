require "propshaft/asset"

class Propshaft::LoadPath
  attr_reader :paths

  def initialize(paths = [])
    @paths = paths
  end

  def append(path)
    @paths.append path
  end

  def prepend(path)
    @paths.prepend path
  end

  def find(asset_name)
    mapped_assets[asset_name]
  end

  def mapped_assets
    @assets ||= Hash.new.tap do |mapped|
      paths.each do |path|
        all_files_from_tree(path).each do |file|
          logical_path = file.relative_path_from(path)
          mapped[logical_path.to_s] ||= Propshaft::Asset.new(file, logical_path: logical_path)
        end
      end
    end
  end

  def assets
    mapped_assets.values
  end

  def manifest
    Hash.new.tap do |manifest|
      assets.each do |asset|
        manifest[asset.logical_path] = asset.digested_path
      end
    end
  end

  private
    def all_files_from_tree(path)
      path.children.flat_map { |child| child.directory? ? all_files_from_tree(child) : child }
    end
end