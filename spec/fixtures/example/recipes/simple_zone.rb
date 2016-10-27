include_recipe 'named'

named_zone_file 'test.fr' do
  primary_ns 'ns.test.fr'
  hostmaster 'contact.lta.io'
  serial '1234'
  records [
    { data: '1.1.1.1' },
    { name: 'ns', type: 'NS', data: '1.1.1.2' },
    { name: 'mx', type: 'MX', prio: 10, data: '1.1.1.3' },
    { name: 'cname', type: 'CNAME', data: 'test.fr.' },
  ]
end
