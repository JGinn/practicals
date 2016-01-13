require_relative "counter"

module Measurement
  class ConditionCounter < Counter

    def on_if(node)
      super node
      # Must have else part
      unless node.children[1] == nil || node.children[2] == nil
        increment
      end
    end

    def on_send(node)
      super node
      if [:==, :!=, :<=, :>=, :<, :>].include?(node.children[1])
        increment
      end
    end

    def on_case(node)
      super(node)
      # The first child is the condition itself, don't increment for that.
      (node.children.size - 1).times do |i|
        increment
      end
    end

    def on_or(node)
      super node
      increment
    end

    def on_and(node)
      super node
      increment
    end

    def on_rescue(node)
      super node
      increment
    end
  end
end
