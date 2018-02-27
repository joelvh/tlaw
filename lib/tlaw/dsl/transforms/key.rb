require_relative 'base'

module TLAW
  module DSL
    module Transforms
      class Key < Base
        def self.build(key = nil, &block)
          key ? Key.new(key, &block) : Base.new(&block)
        end

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
    end
  end
end
