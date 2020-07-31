require 'test_helper'

if ENV.fetch('ACTIVEMODEL_VERSION', '6.1') <= '6.0.0'

  module Micro::Case::WithValidation::Safe
    module ClassesWithFlows
      class AllStepsWithValidationTest < Minitest::Test
        class ConvertTextToNumber < Micro::Case::Safe
          attribute :text

          validates :text, presence: true

          def call!
            number = text.include?('.') ? text.to_f : text.to_i

            Success result: { number: number }
          end
        end

        class ConvertNumberToText < Micro::Case::Safe
          attribute :number

          validates :number, presence: true

          def call!
            Success result: { text: number.to_s }
          end
        end

        class Double < Micro::Case::Safe
          flow ConvertTextToNumber,
              self.call!,
              ConvertNumberToText

          attribute :number

          validates :number, kind: Integer

          def call!
            Success result: { number: number * 2 }
          end
        end

        def test_the_use_case_result
          assert_failure_result(Double.call(text: ''), type: :validation_error)

          # ---

          result = Double.call(text: '4')

          assert_success_result(result, value: { text: '8' })

          assert_equal(
            [ConvertTextToNumber, Double::Flow_Step, ConvertNumberToText],
            Double.use_cases
          )

          # ---

          result = Double.call(text: '4.0')

          assert_failure_result(result, type: :validation_error)

          assert_equal(['must be a kind of: Integer'], result.value[:errors][:number])
        end
      end
    end
  end

end
