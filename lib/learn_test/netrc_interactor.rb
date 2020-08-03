# frozen_string_literal: true

require 'netrc'

module LearnTest
  class NetrcInteractor
    attr_reader :username, :user_id, :netrc, :machine

    def initialize(machine: 'flatiron-push')
      @machine = machine
      @netrc = Netrc.read
      @username, @user_id = netrc[machine]
    end

    def write(username, user_id)
      netrc[machine] = username, user_id
      netrc.save
    end
  end
end
