maintainer "Julien 'Lta' BALLET"
maintainer_email 'contact@lta.io'
license 'Apache 2.0'
description 'Installs/Configures ISC BIND, generate zonefiles'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '0.0.1'
name 'named'

depends 'chef-sugar'
