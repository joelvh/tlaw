require_relative 'transforms/base'
require_relative 'transforms/items'
require_relative 'transforms/items_batch'
require_relative 'transforms/key'
require_relative 'transforms/replace'

module TLAW
  module DSL
    class BaseWrapper
      def initialize(object)
        @object = object
      end

      def define(&block)
        instance_eval(&block)
      end

      def description(text)
        # first, remove spaces at a beginning of each line
        # then, remove empty lines before and after docs block
        @object.description =
          text
          .gsub(/^[ \t]+/, '')
          .gsub(/\A\n|\n\s*\Z/, '')
      end

      alias_method :desc, :description

      def docs(link)
        @object.docs_link = link
      end

      def param(name, type = nil, **opts)
        @object.param_set.add(name, **opts.merge(type: type))
      end

      def response_processor(processor)
        @object.response_processor = processor
      end

      def transform(key = nil, replace: false, &block)
        @object.response_processor.processors << Transforms.build(key, replace: replace, &block)
      end

      def transform_item(key, subkey = nil, &block)
        @object.response_processor.processors << Transforms::Items.new(key, subkey, &block)
      end

      def transform_items(key, &block)
        @object.response_processor.processors.concat Transforms::ItemsBatch.batch(key, &block)
      end

      # Backwards-compatibility

      alias_method :process, :transform
      alias_method :process_item, :transform_item
      alias_method :process_items, :transform_items

      def process_replace(&block)
        transform(replace: true, &block)
      end
    end
  end
end
