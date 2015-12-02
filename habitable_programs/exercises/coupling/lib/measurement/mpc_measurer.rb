require_relative "../../../common/lib/measurement/measurer"
require_relative "../../../common/lib/locator/method_locator"

module Measurement
  class MPCMeasurer < Measurer
    def locator
      Locator::MethodLocator.new
    end

    def measurements_for(method)
      messages = messages_for(method)

      total = messages.size
      to_self = messages.find_all { |message|
        message.children[0] == nil
      }.size

      to_ancestors = messages.find_all { |message|
        message.children[0] ? message.children[0].type == :zsuper : false
      }.size

      mpc = total - (to_self + to_ancestors)

      {
        total_messages_passed: total,
        messages_passed_to_self: to_self,
        messages_passed_to_ancestors: to_ancestors,
        mpc: mpc
      }
    end

    def messages_for(method)
      finder = MessageFinder.new
      finder.process(method.ast)
      finder.messages
    end
  end

  class MessageFinder < Parser::AST::Processor
    attr_reader :count

    def on_send(node)
      super
      messages << node
    end

    def messages
      @messages ||= []
    end
  end
end
