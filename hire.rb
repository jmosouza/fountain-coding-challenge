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
      'ADVANCE' => :define_applicant,
      'DECIDE' => :define_applicant,
      'STATS' => :show_stats
    }.freeze

    VALID_STAGES =
      %w[ManualReview PhoneInterview BackgroundCheck DocumentSigning].freeze

    INVALID_COMMAND_MESSAGE = 'Invalid command'.freeze
    DUPLICATE_APPLICANT_MESSAGE = 'Duplicate applicant'.freeze

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
  end
end

hire = Hire::Service.new

while (cmd = gets.strip) && !cmd.empty?
  hire.parse_command(cmd)
end
