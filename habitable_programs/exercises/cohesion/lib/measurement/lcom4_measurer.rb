require_relative "../../../common/lib/measurement/measurer"
require_relative "../../../common/lib/locator/module_locator"
require_relative "dependency_graph"

module Measurement
  class LCOM4Measurer < Measurer
    def locator
      Locator::ModuleLocator.new
    end

    def measurements_for(clazz)
      dependencies = process(clazz)

      {
        lcom4: dependencies.number_of_components,
        connected_components: dependencies.components_summary
      }
    end

    def process(clazz)
      processor = ClassProcessor.new(clazz.ast)
      processor.process(clazz.ast)
      processor.dependencies
    end
  end

  class ClassProcessor < Parser::AST::Processor
    def initialize(root)
      @root = root
    end

    # Ignore nested modules
    def on_module(ast)
      super if ast == @root
    end

    # Ignore nested classes
    def on_class(ast)
      super if ast == @root
    end

    def on_def(ast)
      super

      call_method = ast.children[0]
      return if call_method == :initialize

      method_processor = MethodProcessor.new
      method_processor.process(ast)

      dependencies.add_all(call_method, method_processor.dependees)
    end

    def dependencies
      @dependencies ||= DependencyGraph.new
    end
  end

  class MethodProcessor < Parser::AST::Processor
    def dependees
      @dependees ||= []
    end

    def on_send(node)
      super
      reciever, method = node.children
      if reciever.nil?
        dependees << method
      elsif reciever.type == :ivar
        dependees << reciever.children[0]
      end
    end
  end
end
