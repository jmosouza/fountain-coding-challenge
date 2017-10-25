module Hire
  # A job applicant.
  class Applicant
    attr_accessor :email
    attr_accessor :stage

    def initialize(email:, stage:)
      @email = email
      @stage = stage
    end

    # Two instances refer to the same applicant if both have same email.
    # DEVNOTE: Avoid `case` here, it doesn't work with `Object#class`.
    def ==(other)
      if other.is_a? Applicant
        @email == other.email
      elsif other.is_a? String
        @email == other
      else
        false
      end
    end

    def hired=(hired)
      self.stage = hired ? 'Hired' : 'Rejected'
    end
  end

  # A hiring service that handles custom commands.
  class Service
    COMMAND_MAP = {
      'DEFINE' => :define_stages,
      'CREATE' => :create_applicant,
      'ADVANCE' => :advance_applicant,
      'DECIDE' => :decide_applicant,
      'STATS' => :show_stats
    }.freeze

    VALID_STAGES =
      %w[ManualReview PhoneInterview BackgroundCheck DocumentSigning].freeze

    MSG_ALREADY_IN = 'Already in '.freeze
    MSG_DUPLICATE_APPLICANT = 'Duplicate applicant'.freeze
    MSG_INVALID_COMMAND = 'Invalid command'.freeze
    MSG_INVALID_STAGE = 'Invalid stage'.freeze
    MSG_REJECTED = 'Rejected '.freeze
    MSG_HIRED = 'Hired '.freeze
    MSG_FAILED_TO_DECIDE = 'Failed to decide for '.freeze

    def initialize(out = nil)
      @out = out
      @stages = []
      @applicants = []
    end

    # Call the method corresponding to a command.
    def parse_command(cmd)
      cmd_name, *cmd_args = cmd.split
      method_name = COMMAND_MAP[cmd_name] || ''.freeze
      send(method_name, cmd, *cmd_args)
    rescue ArgumentError, NoMethodError
      output MSG_INVALID_COMMAND
    end

    private

    # Print a message to @out or stdout, whichever handles `puts`.
    def output(msg)
      @out.respond_to?(:puts) ? @out.puts(msg) : puts(msg)
    end

    # Define the stages in the hiring process. The available stages are
    # `ManualReview PhoneInterview BackgroundCheck DocumentSigning`.
    def define_stages(cmd, *stages)
      @stages = VALID_STAGES & stages
      output cmd
    end

    # Create an applicant with the specified email address.
    # Check if the applicant is already in the system before creating a new one.
    def create_applicant(cmd, email)
      if @applicants.include? email
        output MSG_DUPLICATE_APPLICANT
      else
        @applicants << Applicant.new(email: email, stage: @stages.first)
        output cmd
      end
    end

    # Advance the applicant to the specified stage.
    # If `stage` parameter is omitted, advance the applicant to the next stage.
    def advance_applicant(cmd, email, stage = ''.freeze)
      applicant = find_applicant(email)
      if !applicant
        output MSG_NO_SELECTED_APPLICANT
      elsif [stage, @stages.last].include? applicant.stage
        output MSG_ALREADY_IN + applicant.stage
      elsif stage.empty?
        stage_index = @stages.index(applicant.stage) || -1
        applicant.stage = @stages[stage_index + 1]
        output cmd
      elsif !@stages.include?(stage)
        output MSG_INVALID_STAGE
      else
        applicant.stage = stage
        output cmd
      end
    end

    def decide_applicant(_, email, decision)
      applicant = find_applicant(email)
      hired = decision == '1'.freeze
      if !hired
        applicant.hired = false
        output MSG_REJECTED + email
      elsif applicant.stage == @stages.last
        applicant.hired = true
        output MSG_HIRED + email
      else
        output MSG_FAILED_TO_DECIDE + email
      end
    end

    def show_stats(_)
      stats = (@stages + ['Hired', 'Rejected']).map do |s|
        [s, @applicants.count { |a| a.stage == s }]
      end.flatten.join(' ')
      output stats
    end

    def find_applicant(email)
      @applicants.find { |a| a.email == email }
    end
  end
end

file_input = File.new('input.txt', 'r')
file_output = File.new('output.txt', 'w')
hire = Hire::Service.new(file_output)

while (cmd = file_input.gets)
  hire.parse_command(cmd.strip)
end
