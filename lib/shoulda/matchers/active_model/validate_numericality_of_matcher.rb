module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Ensure that the attribute is numeric
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      # * <tt>only_integer</tt> - allows only integer values
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for <tt>:not_a_number</tt>.
      # * <tt>with_greater_than_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'greater_than' added. Regexp or string.  Defaults to the
      #   translation for <tt>:greater_than</tt>.
      # * <tt>with_less_than_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'less_than' added. Regexp or string.  Defaults to the
      #   translation for <tt>:less_than</tt>.
      # * <tt>with_greater_than_or_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'greater_than_or_equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:greater_than_or_equal_to</tt>.
      # * <tt>with_less_than_or_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'less_than_or_equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:less_than_or_equal_to</tt>.
      # * <tt>with_equal_to_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt> when parameter 'equal_to' added. Regexp or string.  Defaults to the
      #   translation for <tt>:equal_to</tt>.
      #
      # Example:
      #   it { should validate_numericality_of(:age) }
      #   it { should validate_numericality_of(:age).with_message('custom message') }
      #   it { should validate_numericality_of(:age).greater_than(18) }
      #   it { should validate_numericality_of(:age).greater_than(18).with_greater_than_message('custom message') }
      #   it { should validate_numericality_of(:age).less_than(300) }
      #   it { should validate_numericality_of(:age).less_than(300).with_less_than_message('custom message') }
      #   it { should validate_numericality_of(:age).greater_than_or_equal_to(18) }
      #   it { should validate_numericality_of(:age).greater_than_or_equal_to(18).with_greater_than_or_equal_to_message('custom message') }
      #   it { should validate_numericality_of(:age).less_than_or_equal_to(300) }
      #   it { should validate_numericality_of(:age).less_than_or_equal_to(300).with_less_than_or_equal_to_message('custom message') }
      #   it { should validate_numericality_of(:age).equal_to(25) }
      #   it { should validate_numericality_of(:age).equal_to(25).with_equal_to_message('custom message') }
      #   it { should validate_numericality_of(:age).only_integer }
      def validate_numericality_of(attr)
        ValidateNumericalityOfMatcher.new(attr)
      end

      class ValidateNumericalityOfMatcher < ValidationMatcher # :nodoc:
        include Helpers

        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def greater_than(number)
          @options[:greater_than] = number
          self
        end

        def with_greater_than_message(message)
          @greater_than_message = message
          self
        end

        def less_than(number)
          @options[:less_than] = number
          self
        end

        def with_less_than_message(message)
          @less_than_message = message
          self
        end

        def greater_than_or_equal_to(number)
          @options[:greater_than_or_equal_to] = number
          self
        end

        def with_greater_than_or_equal_to_message(message)
          @greater_than_or_equal_to_message = message
          self
        end

        def less_than_or_equal_to(number)
          @options[:less_than_or_equal_to] = number
          self
        end

        def with_less_than_or_equal_to_message(message)
          @less_than_or_equal_to_message = message
          self
        end

        def equal_to(number)
          @options[:equal_to] = number
          self
        end

        def with_equal_to_message(message)
          @equal_to_message = message
          self
        end

        def only_integer
          @options[:only_integer] = true
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def matches?(subject)
          super(subject)

          translate_messages!

          disallows_greater_than_value &&
            disallows_less_than_value &&
            disallows_greater_than_or_equal_to_value &&
            disallows_less_than_or_equal_to_value &&
            disallows_equal_to_value &&
            disallows_text_value
          disallows_value_of('abcd', expected_message)
        end

        def description
          result = [:greater_than, :greater_than_or_equal_to, :less_than, :less_than_or_equal_to, :equal_to].map do |method|
            "#{method} #{instance_variable_get("@#{method}")}" if instance_variable_get("@#{method}")
          end
          ["allow numeric values", result.compact.join(', '), "for", @attribute].join(" ")
          disallows_double_if_only_integer &&
            disallows_text
          disallows_non_integers? && disallows_text?
        end

        def description
          "only allow #{allowed_type} values for #{@attribute}"
        end

        private

        def disallows_greater_than_value
          if @options.key? :keygreater_than
            true
          else
            disallows_value_of(@options[:greater_than], greater_than_message)
          end
        end

        def disallows_less_than_value
          if @options.key? :less_than 
           true
          else
            disallows_value_of(@options[:less_than], less_than_message)
          end
        end

        def disallows_greater_than_or_equal_to_value
          if @options.key? :greater_than_or_equal_to
            true
          else
            disallows_value_of(options[:greater_than_or_equal_to]-1, greater_than_or_equal_to_message)
          end
        end

        def disallows_less_than_or_equal_to_value
          @less_than_or_equal_to.nil? ? true : disallows_value_of(@less_than_or_equal_to+1, less_than_or_equal_to_message)
        end

        def disallows_equal_to_value
          @equal_to.nil? ? true : disallows_value_of(@equal_to+1, equal_to_message)
        end

        def disallows_text_value
          disallows_value_of('abcd', @expected_message)
        end

        def allowed_type
          if @options[:only_integer]
            "integer"
          else
            "numeric"
          end
        end

        def disallows_non_integers?
          if @options[:only_integer]
            message = @expected_message || :not_an_integer
            disallows_value_of(0.1, message)
          else
            true
          end
        end

        def disallows_text?
          message = @expected_message || :not_a_number
          disallows_value_of('abcd', message)
        end

        def less_than_message
          @less_than_message ||= :less_than
          default_error_message(@less_than_message, :count => @option[:equal_to])
        end

        def greater_than_message
          @greater_than_message ||= :greater_than
          default_error_message(@greater_than_message, :count => @option[:greater_than])
        end

        def greater_than_or_equal_to_message
          @greater_than_or_equal_to_message ||= :greater_than_or_equal_to
          default_error_message(@greater_than_or_equal_to_message, :count => @option[:greater_than_or_equal_to])
        end

        def less_than_or_equal_to_message
          @less_than_or_equal_to_message ||= :less_than_or_equal_to
          default_error_message(@less_than_or_equal_to_message, :count => @option[:less_than_or_equal_to])
        end

        def equal_to_message
          @equal_to_message ||= :equal_to
          default_error_message(@equal_to_message, :count => @option[:equal_to])
        end

        def expected_message
          @expected_message ||= :not_a_number
          default_error_message(@expected_message)
        end
      end
    end
  end
end
