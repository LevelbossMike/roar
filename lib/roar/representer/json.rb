require 'roar/representer'
require 'representable/json'

module Roar
  module Representer
    module JSON
      def self.included(base)
        base.class_eval do
          include Representer
          include Representable::JSON
          
          extend ClassMethods
          include InstanceMethods # otherwise Representable overrides our #to_json.

          def setup_for_json(opts={})
            opts.each do |key, val| 
              instance_variable = "@#{key}".to_sym
              raise "instance variable #{instance_variable} already defined" if instance_variable_defined? instance_variable
              instance_variable_set instance_variable, val
            end
          end
        end
      end
      
      module InstanceMethods
        def to_hash(*args)
          before_serialize(*args)
          super
        end
        
        def from_json(document, options={})
          document ||= "{}" # DISCUSS: provide this for convenience, or better not?
          
          super
        end
        
        # Generic entry-point for rendering.
        def serialize(*args)
          to_json(*args)
        end
        
        def deserialize(*args)
          from_json(*args)
        end
      end
      
      
      module ClassMethods
        def deserialize(json)
          from_json(json)
        end
        
        # TODO: move to instance method, or remove?
        def links_definition_options
          {:class => Hyperlink , :collection => true}
        end
      end
      
      
      # Encapsulates a hypermedia link.
      class Hyperlink
        include JSON
        attr_accessor :rel, :href
        
        property :rel
        property :href
      end
    end
  end
end
