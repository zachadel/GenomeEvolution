extends Reference

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#Convention: matrix[from][to] = conversion rate (float)
var matrix = {}

var row_labels = []
var column_labels = []

func setup(_row_labels: Array, _column_labels: Array, values: Dictionary = {}):
	if values == {}:
		for r_label in _row_labels:
			row_labels.append(r_label)
			matrix[r_label] = {}
			for c_label in _column_labels:
				matrix[r_label][c_label] = 0
		
	else:
		for r_label in _row_labels:
			row_labels.append(r_label)
			matrix[r_label] = {}
			for c_label in _column_labels:
				matrix[r_label][c_label] = values[r_label][c_label]
				
	for c_label in _column_labels:
			column_labels.append(c_label)

			
#values[column_label] = value
func add_row(row_label, values: Dictionary):
	row_labels.append(row_label)
	
	matrix[row_label] = {}
	
	for column_label in column_labels:
		matrix[row_label][column_label] = values[column_label]
		
func add_column(column_label, values: Dictionary):
	column_labels.append(column_label)
	
	for row_label in matrix:
		matrix[row_label][column_label] = values[row_label]

#values[_column_labels[i]] = {row_label1: value,..., row_labelN: value}
func add_columns(_column_labels: Array, values: Dictionary):
	for column_label in _column_labels:
		add_column(column_label, values[column_label])

#values[_row_labels[i]] = {column_label1: value,..., column_labelN: value}
func add_rows(_row_labels: Array, values: Dictionary):
	for row_label in _row_labels:
		add_row(row_label, values[row_label])
		
func sum_row(row_label):
	var sum = 0
	for column_label in matrix[row_label]:
		sum += matrix[row_label][column_label]
		
	return sum
	
func sum_column(column_label):
	var sum = 0
	for row_label in matrix:
		sum += matrix[row_label][column_label]
		
	return sum
	
func sum_diagonal():
	var sum = 0
	
	if len(row_labels) == len(column_labels):
		for i in range(len(row_labels)):
			sum += matrix[row_labels[i]][column_labels[i]]
			
	else:
		print('ERROR: Cannot sum diagonal of non-square matrix')
		
	return sum
	
func sum_all_values():
	var sum = 0
	
	for row_label in row_labels:
		for column_label in column_labels:
			sum += matrix[row_label][column_label]
#Component wise multiplication of self entries by matrix entries
func hadamard_product(matrix):
	var matrix_n_rows = matrix.get_number_of_rows()
	var matrix_n_cols = matrix.get_number_of_columns()
	
	var n_rows = get_number_of_rows()
	var n_cols = get_number_of_columns()
	if matrix_n_rows == n_rows and matrix_n_cols == n_cols:
		for i in range(n_rows):
			for j in range(n_cols):
				matrix[row_labels[i]][column_labels[j]] *= matrix.matrix[matrix.row_labels[i]][matrix.column_labels[j]]

func get_row_labels():
	return row_labels
	
func get_number_of_rows():
	return len(row_labels)
	
func get_column_labels():
	return column_labels
	
func get_number_of_columns():
	return len(column_labels)
	
func get_value(row_label, column_label):
	return matrix[row_label][column_label]
	
func get_values(row_labels: Array, column_labels: Array):
	var return_dict = {}
	
	for row_label in row_labels:
		return_dict[row_label] = {}
		for column_label in column_labels:
			return_dict[row_label][column_label] = matrix[row_label][column_label]
			
	return return_dict
	
#Returns new_vector[column_label] = value
func add_row_vector_to_row_vector(row_label1, row_label2):
	var new_vector = {}
	
	for entry in matrix[row_label1]:
		new_vector[entry] = matrix[row_label1][entry] + matrix[row_label2][entry]
		
	return new_vector

func sum_row_vectors():
	var new_vector = {}
	
	for column_label in column_labels:
		new_vector[column_label]  = 0
		for row_label in row_labels:
			new_vector[column_label] += matrix[row_label][column_label]
			
	return new_vector
	
func add_column_vector_to_column_vector(column_label1, column_label2):
	var new_vector = {}
	
	for entry in row_labels:
		new_vector[entry] = matrix[entry][column_label1] + matrix[entry][column_label2]
		
	return new_vector
	
func sum_column_vectors():
	var new_vector = {}
	
	for row_label in row_labels:
		new_vector[row_label] = 0
		for column_label in column_labels:
			new_vector[row_label] += matrix[row_label][column_label]
			
	return new_vector

func set_value(row_label, column_label, value: float):
	matrix[row_label][column_label] = value
	
func scale_row(row_label, scale: float):
	for column_label in matrix[row_label]:
		matrix[row_label][column_label] *= scale
		
func scale_column(column_label, scale: float):
	for row_label in matrix:
		matrix[row_label][column_label] *= scale
		
func scale_point(row_label, column_label, scale: float):
	matrix[row_label][column_label] *= scale
	
#Values should be indexed by the column labels
func set_row(row_label, values: Dictionary):
	for column_label in matrix[row_label]:
		matrix[row_label][column_label] = values[column_label]

#Values should be indexed by the row labels
func set_column(column_label, values: Dictionary):
	for row_label in matrix:
		matrix[row_label][column_label] = values[row_label]
	
func shallow_copy_array(array: Array):
	var new_array = []
	
	for obj in array:
		new_array.append(obj)
		
	return new_array
	
func is_same_size(matrix):
	var matrix_n_rows = matrix.get_number_of_rows()
	var matrix_n_cols = matrix.get_number_of_columns()
	
	var n_rows = get_number_of_rows()
	var n_cols = get_number_of_columns()
	
	if matrix_n_rows == n_rows and matrix_n_cols == n_cols:
		return true
	else:
		return false
		
func copy_values(matrix):
	if is_same_size(matrix):
		var n_rows = get_number_of_rows()
		var n_cols = get_number_of_columns()
		
		for i in range(n_rows):
			for j in range(n_cols):
				matrix[row_labels[i]][column_labels[j]] = matrix.matrix[matrix.row_labels[i]][matrix.column_labels[j]]