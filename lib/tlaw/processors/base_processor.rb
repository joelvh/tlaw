module TLAW
  module Processors
    # @private
    # FIXME: everything is awfully dirty here
    class BaseProcessor
      attr_reader :processors
      attr_accessor :parent

      def initialize(processors = [])
        @processors = processors
      end

      def call(response)
        all_processors.reduce(response) { |result, processor| process(processor, result) }
      end

      def process(processor, obj)
        processor.call(obj)
      end

      def all_processors
        [*(parent && parent.all_processors), *@processors]
      end
    end
  end
end
