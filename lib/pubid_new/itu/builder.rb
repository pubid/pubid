module PubidNew
  module Itu
    class Builder
      attr_reader :scheme
      
      def initialize(scheme)
        @scheme = scheme
      end
      
      def build(parsed_data)
        # Transform parsed data using scheme
        attributes = scheme.transform(parsed_data)
        
        # Create model instance
        model = scheme.model_class.new(attributes)
        
        model
      end
    end
  end
end