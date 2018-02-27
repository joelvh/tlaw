require_relative 'items'

module TLAW
  module DSL
    module Transforms
      class ItemsBatch
        def initialize(parent_key, parent)
          @parent_key = parent_key
          @parent = parent
        end
  
        def process(key = nil, &block)
          @parent.processors << Items.new(@parent_key, key, &block)
        end
      end
    end
  end
end
