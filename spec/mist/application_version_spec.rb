require 'spec_helper'

describe Mist::ApplicationVersion do
  context 'Valid version' do
    When(:result) { Mist::ApplicationVersion.new(version: 'git-24f16d3727b0271c89e213d6ded27f986dfb5436-1380729401417') }
    Then { result != Failure(RuntimeError) }
    Then { result.sha == '24f16d3727b0271c89e213d6ded27f986dfb5436' }
    Then { result.version_control == 'git' }
    Then { result.stamp == '1380729401417' }
  end

  context 'Invalid Version' do
    context 'No Version' do
      When(:result) { Mist::ApplicationVersion.new }
      Then { result == Failure(RuntimeError, 'The specified version is invalid.') }
    end

    context 'Bad Version' do
      context 'no dash' do
        When(:result) { Mist::ApplicationVersion.new(version: 'DONKEY') }
        Then { result == Failure(RuntimeError, "The specified version 'DONKEY' is invalid.") }
      end

      context 'one dash' do
        When(:result) { Mist::ApplicationVersion.new(version: 'DONKEY-DONKEY') }
        Then { result == Failure(RuntimeError, "The specified version 'DONKEY-DONKEY' is invalid.") }
      end

      context 'three dashes' do
        When(:result) { Mist::ApplicationVersion.new(version: 'DONKEY-DONKEY-DONKEY-DONKEY') }
        Then { result == Failure(RuntimeError, "The specified version 'DONKEY-DONKEY-DONKEY-DONKEY' is invalid.") }
      end
    end
  end
end
