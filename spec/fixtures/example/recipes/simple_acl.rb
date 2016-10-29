include_recipe 'named'

named_acl 'my_acl' do
  match [
    'localnets',
    '10.0.0.0/24',
  ]

  options [
    'opt1;'
  ]
end

named_acl 'default_acl'
