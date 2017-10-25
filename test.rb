require 'byebug'
require './hire'

def assert_equal(f1, f2, msg)
  if f1 == f2
    true
  else
    puts(msg)
    false
  end
end

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
  assert_equal(file_output.read, file_assert.read, "Example #{n} failed.") || exit
end

puts '👍'
