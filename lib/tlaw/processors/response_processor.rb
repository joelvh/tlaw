require_relative 'base_processor'
require 'json'
require 'crack'

module TLAW
  module Processors
    # @private
    # FIXME: everything is awfully dirty here
    class ResponseProcessor < BaseProcessor
      class Base
        def initialize(&block)
          @block = block
        end

        def call(hash)
          hash.tap(&@block)
        end

        def to_proc
          method(:call).to_proc
        end
      end

      class Key < Base
        def initialize(key, &block)
          @key = key
          super(&block)
        end

        def call(hash)
          return hash unless hash.is_a?(Hash)
          hash.keys.grep(@key).inject(hash) do |res, k|
            res.merge(k => @block.call(hash[k]))
          end
        end
      end

      class Replace < Base
        def call(hash)
          @block.call(hash)
        end
      end

      class Items < Base
        def initialize(key, subkey = nil, &block)
          @key = key
          @item_processor = subkey ? Key.new(subkey, &block) : Base.new(&block)
        end

        def call(hash)
          return hash unless hash.is_a?(Hash)
          hash.keys.grep(@key).inject(hash) do |res, k|
            next res unless hash[k].is_a?(Array)
            res.merge(k => hash[k].map(&@item_processor))
          end
        end
      end

      def add_processor(key = nil, &block)
        @processors << (key ? Key.new(key, &block) : Base.new(&block))
      end

      def add_replacer(&block)
        @processors << Replace.new(&block)
      end

      def add_item_processor(key, subkey = nil, &block)
        @processors << Items.new(key, subkey, &block)
      end

      def call(response)
        guard_errors!(response)

        datablize(super parse_response(response))
      end

      private

      def guard_errors!(response)
        # TODO: follow redirects
        return response if (200...400).cover?(response.status)

        body = JSON.parse(response.body) rescue nil
        message = body && (body['message'] || body['error'])

        fail API::Error,
             "HTTP #{response.status} at #{response.env[:url]}" +
             (message ? ': ' + message : '')
      end

      def parse_response(response)
        hash = if response.headers['Content-Type'] =~ /xml/
                 Crack::XML.parse(response.body)
               else
                 JSON.parse(response.body)
               end

        flatten hash
      end

      def flatten(value)
        case value
        when Hash
          flatten_hash(value)
        when Array
          value.map(&method(:flatten))
        else
          value
        end
      end

      def flatten_hash(hash)
        hash.flat_map do |k, v|
          v = flatten(v)
          if v.is_a?(Hash)
            v.map { |k1, v1| ["#{k}.#{k1}", v1] }
          else
            [[k, v]]
          end
        end.reject { |_, v| v.nil? }.to_h
      end

      def process(processor, res)
        flatten super
      end

      def datablize(value)
        case value
        when Hash
          value.map { |k, v| [k, datablize(v)] }.to_h
        when Array
          if !value.empty? && value.all? { |el| el.is_a?(Hash) }
            DataTable.new(value)
          else
            value
          end
        else
          value
        end
      end
    end
  end
end
