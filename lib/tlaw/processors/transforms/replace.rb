require_relative 'base'

module TLAW
  module Processors
    module Transforms
      class Replace < Base
        def call(hash)
          @block.call(hash)
        end
      end
    end
  end
end
