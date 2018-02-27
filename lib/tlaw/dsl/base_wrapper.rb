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

      def process(key = nil, &block)
        @object.response_processor.processors << (key ? Transforms::Key.new(key, &block) : Transforms::Base.new(&block))
      end

      def process_replace(&block)
        @object.response_processor.processors << Transforms::Replace.new(&block)
      end

      def process_item(key, subkey = nil, &block)
        @object.response_processor.processors << Transforms::Items.new(key, subkey, &block)
      end

      def process_items(key, &block)
        Transforms::ItemsBatch
          .new(key, @object.response_processor)
          .instance_eval(&block)
      end
    end
  end
end
