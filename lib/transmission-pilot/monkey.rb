module TransmissionPilot
  module Monkey
    module Object
      def blank?
        respond_to?(:empty?) ? empty? : !self
      end

      def present?
        !blank?
      end

      def number?
        is_a? Numeric
      end

      def filesize?
        number? && positive?
      end
    end

    module Hash
      def symbolized
        inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end

      def stringified
        inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
      end
    end

    module Numeric
      def positive?
        self > 0
      end

      def negative?
        self < 0
      end
    end
  end
end

class Object
  include TransmissionPilot::Monkey::Object
end

class Hash
  include TransmissionPilot::Monkey::Hash
end

class Numeric
  include TransmissionPilot::Monkey::Numeric
end
