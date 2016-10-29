# Named [![Build Status](https://secure.travis-ci.org/elthariel/cookbook-named.png?branch=master)](http://travis-ci.org/elthariel/cookbook-named)

## Description

A cookbook to install and configure DNS BIND server as well as
generate zone files with a fancy DSL. While allowing other setups,
this cookbook emphasis in on managing a split-horizon authoritative
server.

This cookbook has been forked from the 'bind' community cookbook. 
Some features like databag/ldap acl/zone configuration support have 
been removed in favor of a DSL based approach using resources.

To get started quickly, see the example in the [Usage](#usage) section.

## Requirements

- Chef 12+ (developped on 12.9)
- Debian/Ubuntu (Support for other platform is likely to be very easy to add and is very welcome)

## Attributes

### Attributes which probably require tuning

* `bind['masters']`
  - Array of authoritative servers which you transfer zones from.
  - Default empty

* `bind['ipv6_listen']`
  - Boolean, whether BIND should listen on ipv6
  - Default is false

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

* `bind['statistics-channel']`
  - Boolean to enable a statistics-channel on a TCP port.
  - Default, platform-specific

* `bind['statistics-port']`
  - Integer for statistics-channel TCP port.
  - Default, 8080

* `bind['server']`
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

## Resources

Everything zone related in the `named` cookbook is configured using resources.

> All the resources except the `named_zone_file` are *fake* resources, used to gather data for the `named.conf` and `named.options` file, don't use them for notify/subscribes

### named_zone_file

This resource represents a zone file for authoritative DNS. Use it to generate zone from databags or code.

#### Properties

- `name`: The name property of this resource. It is used to generate the file name of the zone file "#{name}.db". If the `origin` property isn't set, the `name` property is used as the origin for the zone.

- `primary_ns`: [required] The primary name server is the SOA field

- `hostmaster`: [required] The hostmaster field of the SOA.

- `serial`: [default = nil] The serial number for the zone. A serial will be generated automatically if you don't provide it. 

- `ttl`: [default = nil] The value of the default ttl (`$TTL`) for the zone file. 


### named_acl

### named_view

### named_zone

## Usage



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
