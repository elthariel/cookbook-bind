# Named [![Build Status](https://secure.travis-ci.org/elthariel/cookbook-named.png?branch=master)](http://travis-ci.org/elthariel/cookbook-named)

## Description

A cookbook to install and configure DNS BIND server as well as
generate zone files with a fancy DSL.

## Requirements

This gem has been developped with chef 12.9

## Attributes

### Attributes which probably require tuning

* `bind['masters']`
  - Array of authoritative servers which you transfer zones from.
  - Default empty

* `bind['ipv6_listen']`
  - Boolean, whether BIND should listen on ipv6
  - Default is false

* `bind['acl-role']`
  - Search key for pulling split-domain ACLs out of `data_bags`
  - Defaults to internal-acl, and has no effect if you do not need ACLs.

* `bind['acl']`
  - An array node attribute which `data_bag` ACLs are pushed on to,
    and then passed to named.options template.
  - Default is an empty array.

* `bind['zones']['attribute']`
  - An array attribute where zone names may be set from role
    attributes.  The dynamic source attributes `bind['zones']['ldap']`
    and `bind['zones']['databag']` will be combined with zone names set
    via role attributes before the named.conf template is rendered.

* `bind['forwardzones']`
  - An array of zones to forward requests for.

* `bind['forwarders']`
  - An array of forwarders to use with the forwardzones.

* `bind['zonetype']`
  - The zone type, master, or slave for configuring
    the  named.conf template.
  - Defaults to slave

* `bind['options']`
  - Free form options for named.conf template
  - Defaults to an empty array.

* `bind['enable_log']`
  - Boolean, toggle bind query logging.  Note this applies only to a dedicated log, such as a query log.
    i.e. bind may still log to the messages/kernel log if configured to do so with syslog.
  - Default to false

* `bind['log_file']`
  - Absolute path to bind log file, assuming directory exists.  Again, this has no effect on syslog
    configuration.
  - Default to `/var/log/bind9/query.log`

* `bind['statistics-channel']
  - Boolean to enable a statistics-channel on a TCP port.
  - Default, platform-specific

* `bind['statistics-port']
  - Integer for statistics-channel TCP port.
  - Default, 8080

* `bind['server']
  - Hash of server IPs, each with their own array of options for the "server" clause.
  - Will not populate by default

### Attributes which should not require tuning

* `bind['packages']`
  - packages to install
  - Platform specific defaults

* `bind['sysconfdir']`
  - etc directory for named
  - Platform specific defaults

* `bind['conf_file']`
  - Full path to named.conf
  - Platform specific defaults

* `bind['options_file']`
  - Full path to named.options
  - Platform specific defaults

* `bind['vardir']`
  - var directory for named to write state data, such as zone files.
  - Platform specific defaults

* `bind['included_files']`
  - Files to be included in named.conf, relative to sysconf (/etc/named, /etc/bind) directory.
    You could, for example, drop off other static files or templates in your sysconf directory.
    Then include them in your named.conf by overriding this attribute.
  - Defaults to named.rfc1912.zones, and named.options

* `bind['var_cookbook_files']`
  - static cookbook files to drop off in var directory
  - defaults to named.empty, named.ca, named.loopback, and named.localhost

* `bind['rndc_keygen']`
  - command to generate rndc key
  - default depends on hardware/hypervisor platform

* `bind['log_options']`
  - Array listing all specific bind logging options
  - default is empty

* `bind['rndc-key']`
  - Location which rndc.key gets created by rndc-confgen

## Usage

### Example role for internal recursing DNS

An example wrapper cookbook for an internal split-horizon BIND server for
example.com, might look like so:

```ruby
# Configure and install Bind to function as an internal DNS server."
# attributes/default.rb
include_attribute 'bind'
default['bind']['acl-role'] = 'internal-acl'
default['bind']['masters'] = %w(192.0.2.10 192.0.2.11 192.0.2.12)
default['bind']['ipv6_listen'] = true
default['bind']['zonetype'] = 'slave'
default['bind']['zonesource'] = 'ldap'
default['bind']['zones']['attribute'] = %w(example.com example.org)
default['bind']['ldap'] = {
  server: 'example.com',
  binddn: 'cn=chef-ldap,ou=Service Accounts,dc=example,dc=com',
  bindpw: 'ServiceAccountPassword',
  domainzones: 'cn=MicrosoftDNS,dc=DomainDnsZones,dc=example,dc=com'
}
default['bind']['options'] = [
  'check-names slave ignore;',
  'multi-master yes;',
  'provide-ixfr yes;',
  'recursive-clients 10000;',
  'request-ixfr yes;',
  'allow-notify { acl-dns-masters; acl-dns-slaves; };',
  'allow-query { example-lan; localhost; };',
  'allow-query-cache { example-lan; localhost; };',
  'allow-recursion { example-lan; localhost; };',
  'allow-transfer { acl-dns-masters; acl-dns-slaves; };',
  'allow-update-forwarding { any; };',
]

# recipes/default.rb
include_recipe 'bind'
```

### Example role for authoritative only external DNS

An example wrapper cookbook for an external split-horizon authoritative only
BIND server for example.com, might look like so:

```ruby
# Configure and install Bind to function as an external DNS server."
# attributes/default.rb
include_attribute 'bind'
default['bind']['acl-role'] = 'external-acl'
default['bind']['masters'] = %w(192.0.2.5 192.0.2.6)
default['bind']['ipv6_listen'] = true
default['bind']['zonetype'] = 'master'
default['bind']['zones']['attribute'] = %w(example.com example.org)
default['bind']['options'] = [
  'recursion no;',
  'allow-query { any; };',
  'allow-transfer { external-private-interfaces; external-dns; };',
  'allow-notify { external-private-interfaces; external-dns; localhost; };',
  'listen-on-v6 { any; };'
]

# recipes/default.rb
include_recipe 'bind'
```

### Example BIND Access Controls from data bag

In order to include an external ACL for the private interfaces
of your external nameservers, you can create a data bag like so.

  * data_bag name: bind
    - id: ACL entry name
    - role: search key for bind data_bag
    - hosts: array of CIDR addresses, or IP addresses

```json
{
  "id": "external-private-interfaces",
  "role": "external-acl",
  "hosts": [ "192.0.2.15", "192.0.2.16", "192.0.2.17" ]
}
```

In order to include an internal ACL for the query addresses of
your LAN, you might create a data bag like so.

  * data_bag name: bind
    - id: ACL entry name
    - role: search key for bind data_bag
    - hosts: array of CIDR addresses, or IP addresses

```json
{
  "id": "example-lan",
  "role": "internal-acl",
  "hosts": [ "192.0.2.18", "192.0.2.19", "192.0.2.20" ]
}
```

### Example to load zone names from data bag

If you have a few number of zones, you can split these
up into individual data bag objects if you prefer.

  * data_bag name: bind
    - zone: string representation of individual zone name.

```json
{
  "id": "example",
  "zone": "example.com"
}
```

If you wish to group a number of zones together, you can
use the following format to include a number of zones at once.

  * data_bag name: bind
    - zones: array representation of several zone names.

```json
{
  "id": "example",
  "zones": [ "example.com", "example.org" ]
}
```

### Example of using the 'server' clause
```ruby
default['bind']['server'] = {
  10.0.0.1: ['keys { my_tsig_key; };', 'bogus no;'],
  10.0.0.2: ['bogus yes;']
}
```

## License and Author

Copyright: 2011 Eric G. Wolfe, 2016 Julien 'Lta' BALLET

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
