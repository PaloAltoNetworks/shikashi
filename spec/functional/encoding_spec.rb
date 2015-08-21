# Encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class EncodingSpec < Minitest::Spec
  include Shikashi

  describe Sandbox, 'Shikashi sandbox' do
    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.run("# encoding: utf-8\n'кириллица'").must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via sandbox run options' do
      Sandbox.new.run("'кириллица'", :encoding => 'utf-8').must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.run("# encoding:        utf-8\n'кириллица'").must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.run("#        encoding: utf-8\n'кириллица'").must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.packet("# encoding: utf-8\n'кириллица'").run.must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via sandbox run options' do
      Sandbox.new.packet("'кириллица'", :encoding => 'utf-8').run.must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.packet("# encoding:        utf-8\n'кириллица'").run.must_equal 'кириллица'
    end

    it 'Should accept UTF-8 encoding via ruby header comments' do
      Sandbox.new.packet("#        encoding: utf-8\n'кириллица'").run.must_equal 'кириллица'
    end
  end
end
