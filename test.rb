require 'byebug'
require './hire'

# Show an error message if the values are not equal.
def assert_equal(expected, actual, msg)
  if expected == actual
    true
  else
    puts(msg)
    puts "\n\nEXPECTED:\n\n"
    puts(expected)
    puts "\n\nACTUAL:\n\n"
    puts(actual)
    false
  end
end

# Change 2 to the number of examples.
# Make sure you put example files in './test' directory with appropriate suffix.
# For example, to add a third test, add 'input_3.txt' and 'assert_3.txt'.
# Files with name 'assert' contains the expected output of the matching 'input'.
2.times do |n|
  n += 1
  file_input = File.new("test/input_#{n}.txt", 'r')
  file_output = File.new("test/output_#{n}.txt", 'w')
  hire = Hire::Service.new(file_output)

  while (cmd = file_input.gets)
    hire.parse_command(cmd.strip)
  end
  file_output.close
  file_output = File.new("test/output_#{n}.txt", 'r')
  file_assert = File.new("test/assert_#{n}.txt", 'r')
  assert_equal(file_assert.read, file_output.read, "Example #{n} failed.") || exit
end

puts '👍'
