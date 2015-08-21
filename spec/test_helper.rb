require 'minitest/autorun'
require 'minitest/reporters'
require 'shikashi'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(color: true)
