require "byebug"

module Hire
  # A job applicant
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
  end

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

    ALREADY_IN_MESSAGE = 'Already in '.freeze
    DUPLICATE_APPLICANT_MESSAGE = 'Duplicate applicant'.freeze
    INVALID_COMMAND_MESSAGE = 'Invalid command'.freeze
    INVALID_STAGE_MESSAGE = 'Invalid stage'.freeze
    REJECTED_MESSAGE = 'Rejected '.freeze
    HIRED_MESSAGE = 'Hired '.freeze
    FAILED_TO_DECIDE_MESSAGE = 'Failed to decide for '.freeze

    def initialize
      @stages = []
      @applicants = []
    end

    # Call the method corresponding to a command.
    def parse_command(cmd)
      cmd_name, *cmd_args = cmd.split
      if (method = COMMAND_MAP[cmd_name])
        send(method, *cmd_args)
      else
        puts INVALID_COMMAND_MESSAGE
      end
    rescue ArgumentError
      puts INVALID_COMMAND_MESSAGE
    end

    private

    # Define the stages in the hiring process. The available stages are
    # `ManualReview PhoneInterview BackgroundCheck DocumentSigning`.
    def define_stages(*stages)
      @stages = VALID_STAGES & stages
    end

    # Create an applicant with the specified email address.
    # Check if the applicant is already in the system before creating a new one.
    def create_applicant(email)
      if @applicants.include? email
        puts DUPLICATE_APPLICANT_MESSAGE
      else
        @applicants << Applicant.new(email: email, stage: @stages.first)
      end
    end

    # Advance the applicant to the specified stage.
    # If `stage` parameter is omitted, advance the applicant to the next stage.
    def advance_applicant(email, stage = ''.freeze)
      applicant = find_applicant(email)
      if !applicant
        puts NO_SELECTED_APPLICANT_MESSAGE
      elsif [stage, @stages.last].include? applicant.stage
        puts ALREADY_IN_MESSAGE + applicant.stage
      elsif stage.empty?
        stage_index = @stages.index(applicant.stage) || -1
        applicant.stage = @stages[stage_index + 1]
      elsif !@stages.include?(stage)
        puts INVALID_STAGE_MESSAGE
      else
        applicant.stage = stage
      end
    end

    def decide_applicant(email, decision)
      applicant = find_applicant(email)
      hired = decision == '1'
      if !hired
        puts REJECTED_MESSAGE + email
      elsif applicant.stage == @stages.last
        puts HIRED_MESSAGE + email
      else
        puts FAILED_TO_DECIDE_MESSAGE + email
      end
    end

    def show_stats
      output = @stages.map do |s|
        [s, @applicants.count { |a| a.stage == s }]
      end.flatten.join(' ')
      puts output
    end

    def find_applicant(email)
      @applicants.find { |a| a.email == email }
    end
  end
end

hire = Hire::Service.new

while (cmd = gets.strip) && !cmd.empty?
  hire.parse_command(cmd)
end
