#
# An example of split horizon master dns
#

include_recipe 'named'

named_acl 'internal' do
  match [ 'localnets' ]
end

named_acl 'external' do
  match [
    '!localnets',
    'any'
  ]
end

named_zone 'internal' do
  view 'internal-view'
end

named_zone 'external' do
  view 'external-view'
end

named_view 'internal-view' do
  clients ['internal']
  recursion true
end

named_view 'external-view' do
  clients ['external']
end
