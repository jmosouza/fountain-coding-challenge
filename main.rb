require './hire'

file_input = File.new('input.txt', 'r')
file_output = File.new('output.txt', 'w')
hire = Hire::Service.new(file_output)

while (cmd = file_input.gets)
  hire.parse_command(cmd.strip)
end
