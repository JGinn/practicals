require_relative "counter"

module Measurement
  class AssignmentCounter < Counter
    
    def on_ivasgn(node)
      super node
      increment
    end

    def on_lvasgn(node)
      super node
      increment
    end
  end
end
