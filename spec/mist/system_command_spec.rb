require 'spec_helper'

describe Mist::Website do
  context 'using backticks' do
    Given(:kernel) { double('Kernel', :` => nil) }
    Given(:system_command) { Mist::SystemCommand.new(kernel) }
    When { system_command.run_command_with_output('test') }
    Then { expect(kernel).to have_received(:`).with('test') }
  end

  context 'using system' do
    Given(:kernel) { double('Kernel', system: nil) }
    Given(:system_command) { Mist::SystemCommand.new(kernel) }
    When { system_command.run_command('test') }
    Then { expect(kernel).to have_received(:system).with('test') }
  end
end
