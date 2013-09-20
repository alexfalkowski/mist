require 'spec_helper'

describe Mist::Website do
  context 'using backticks' do
    context 'with parameters' do
      Given(:kernel) { double('Kernel', :` => nil) }
      Given(:system_command) { Mist::SystemCommand.new(kernel) }
      When { system_command.run_command_with_output('test', 'test') }
      Then { expect(kernel).to have_received(:`).with('test test') }
    end

    context 'without parameters' do
      Given(:kernel) { double('Kernel', :` => nil) }
      Given(:system_command) { Mist::SystemCommand.new(kernel) }
      When { system_command.run_command_with_output('test') }
      Then { expect(kernel).to have_received(:`).with('test') }
    end
  end

  context 'using system' do
    context 'with parameters' do
      Given(:kernel) { double('Kernel', system: nil) }
      Given(:system_command) { Mist::SystemCommand.new(kernel) }
      When { system_command.run_command('test', 'test') }
      Then { expect(kernel).to have_received(:system).with('test test') }
    end

    context 'without parameters' do
      Given(:kernel) { double('Kernel', system: nil) }
      Given(:system_command) { Mist::SystemCommand.new(kernel) }
      When { system_command.run_command('test') }
      Then { expect(kernel).to have_received(:system).with('test') }
    end
  end
end
