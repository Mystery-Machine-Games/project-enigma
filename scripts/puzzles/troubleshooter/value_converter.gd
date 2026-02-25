class ValueConverter:
	static func convert_discrete_to_intermediate(value: Variant, possible_values: Array) -> float:
		var index: float = float(possible_values.find(value))

		if index < 0:
			push_error("given value '%s' does not exist in possible_values: %s" % [
				value, 
				possible_values
			])
			return 0.0

		return index / (possible_values.size() - 1)


	static func convert_float_to_intermediate(value: float, min_value: float, max_value: float) -> float:
		if not min_value < max_value:
			push_error("min_value must be strictly less than max_value")
			return 0.0
		if not (value <= max_value and value >= min_value):
			push_error("given value '%f' was out of the interval [%f, %f]" % [
				value,
				min_value,
				max_value
			])
			return 0.0

		return (value - min_value) / (max_value - min_value)


	static func convert_intermediate_to_discrete(intermediate: float, possible_values: Array) -> Variant:
		if possible_values.is_empty():
			push_error("possible_values is empty")
			return null
		
		return possible_values[roundi(intermediate * (possible_values.size() - 1))]


	static func convert_intermediate_to_float(
			intermediate: float,
			min_value: float,
			max_value: float,
	) -> float:
		if not min_value < max_value:
			push_error("min_value (%f) must be strictly less than max_value (%f)" % [min_value, max_value])
			return 0.0
		if not (intermediate <= 1.0 and intermediate >= 0.0):
			push_error("given intermediate '%f' was out of the valid interval [0.0, 1.0]" % intermediate)
			return 0.0
		
		return (max_value - min_value) * intermediate + min_value
