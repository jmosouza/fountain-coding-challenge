# Process hiring stages and candidates.
class HireService
  COMMAND_MAP = {
    'DEFINE' => :define_stages,
    'CREATE' => :create_applicant,
    'ADVANCE' => :define_applicant,
    'DECIDE' => :define_applicant,
    'STATS' => :show_stats
  }.freeze

  VALID_STAGES =
    %w[ManualReview PhoneInterview BackgroundCheck DocumentSigning].freeze

  INVALID_COMMAND_MESSAGE = 'This command is invalid.'.freeze

  def take_command(cmd)
    cmd_name, *cmd_args = cmd.split
    method = COMMAND_MAP[cmd_name]
    method ? send(method, cmd_args) : puts(INVALID_COMMAND_MESSAGE)
  end

  private

  # Stages passed as argument must be valid.
  # Those that aren't will be ignored.
  def define_stages(stages)
    @stages = VALID_STAGES & stages
  end
end

hire = HireService.new

while (cmd = gets.strip) && !cmd.empty?
  hire.take_command(cmd)
end

puts hire.stages
