require_relative 'post_processor_proxy'

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
        @object.response_processor.add_processor(key, &block)
      end

      def process_replace(&block)
        @object.response_processor.add_replacer(&block)
      end

      def process_items(key, &block)
        PostProcessorProxy
          .new(key, @object.response_processor)
          .instance_eval(&block)
      end
    end
  end
end
