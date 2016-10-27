if defined?(ChefSpec)
  def create_zone_file(name)
    ChefSpec::Matchers::ResourceMatcher.new(:named_zone_file, :create, name)
  end

  def create_zone(name)
    ChefSpec::Matchers::ResourceMatcher.new(:named_zone, :create, name)
  end

  def create_acl(name)
    ChefSpec::Matchers::ResourceMatcher.new(:named_acl, :create, name)
  end

  def create_view(name)
    ChefSpec::Matchers::ResourceMatcher.new(:named_view, :create, name)
  end
end
