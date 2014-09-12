require 'rspec'

module RequestExpectations
	include RSpec

	def expect_json_types(expectations)
		expect_json_types_impl(expectations, body)
	end

	def expect_json(expectations)
		expect_json_impl(expectations, body)
	end

	def expect_status(code)
		expect(response.code).to eq(code)
	end

	private

		def get_mapper
			base_mapper = {
				integer: [Fixnum,Bignum],
				int: [Fixnum,Bignum],
				float: [Float],
				string: [String],
				boolean: [TrueClass, FalseClass],
				bool: [TrueClass, FalseClass],
				object: [Hash],
				array: [Array]
			}

			mapper = base_mapper.clone
			base_mapper.each do |key, value|
				mapper[(key.to_s + "_or_null").to_sym] = value + [NilClass]
			end
			mapper
		end

		def expect_json_types_impl(expectations, hash)
			@mapper ||= get_mapper
			expectations.each do |prop_name, value|
				val = hash[prop_name]
				if val.class == Hash
					expect_json_types_impl(value, val)
				else
					expect(@mapper[value].include?(val.class)).to eq(true), "Expected #{prop_name} to be of type #{value}, got #{val.class} instead"
				end
			end			
		end

		def expect_json_impl(expectations, hash)
			expectations.each do |prop_name, value|
				val = hash[prop_name]
				if(val.class == Hash)
					expect_json_impl(value, val)
				else
					expect(value).to eq(val)
				end
			end
		end
end