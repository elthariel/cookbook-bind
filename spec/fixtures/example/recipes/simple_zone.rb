include_recipe 'named'

named_acl 'test_acl'

named_zone 'default_zone' do
  domain 'test.fr'
end
