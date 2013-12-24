require 'mongoid'

# because Kaminari assumes a Rails environment, we pick it apart and load up only the pieces we need.
require 'kaminari/config'
require 'kaminari/models/page_scope_methods'
require 'kaminari/models/configuration_methods'
require 'kaminari/models/mongoid_extension'
require 'kaminari/models/array_extension'

::Mongoid::Document.send(:include, Kaminari::MongoidExtension::Document)
::Mongoid::Criteria.send(:include, Kaminari::MongoidExtension::Criteria)
