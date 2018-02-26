module TLAW
  module DSL
    class PostProcessorProxy
      def initialize(parent_key, parent)
        @parent_key = parent_key
        @parent = parent
      end

      def process(key = nil, &block)
        @parent.add_item_processor(@parent_key, key, &block)
      end
    end
  end
end
