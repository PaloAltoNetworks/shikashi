# Encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PrivilegesSugarSyntaxSpec < MiniTest::Spec
  include Shikashi

  describe Privileges, 'Shikashi::Privileges' do

    # method chaining
    it 'allow_method should return object of Privileges class' do
      Privileges.allow_method(:foo).must_be_kind_of(Privileges)
    end

    it 'allow_global_read should return object of Privileges class' do
      Privileges.allow_global_read(:$a).must_be_kind_of(Privileges)
    end

    it 'allow_global_write should return object of Privileges class' do
      Privileges.allow_global_write(:$a).must_be_kind_of(Privileges)
    end

    it 'allow_const_read should return object of Privileges class' do
      Privileges.allow_const_read(:$a).must_be_kind_of(Privileges)
    end

    it 'allow_const_write should return object of Privileges class' do
      Privileges.allow_const_write(:$a).must_be_kind_of(Privileges)
    end

    it 'allow_xstr should return object of Privileges class' do
      Privileges.allow_xstr.must_be_kind_of(Privileges)
    end

    it 'instances_of(...).allow() should return object of Privileges class' do
      Privileges.instances_of(Fixnum).allow('foo').must_be_kind_of(Privileges)
    end

    it 'object(...).allow() should return object of Privileges class' do
      Privileges.object(Fixnum).allow('foo').must_be_kind_of(Privileges)
    end

    it 'methods_of(...).allow() should return object of Privileges class' do
      Privileges.methods_of(Fixnum).allow('foo').must_be_kind_of(Privileges)
    end

    it 'instances_of(...).allow() should return object of Privileges class' do
      Privileges.instances_of(Fixnum).allow_all.must_be_kind_of(Privileges)
    end

    it 'object(...).allow() should return object of Privileges class' do
      Privileges.object(Fixnum).allow_all.must_be_kind_of(Privileges)
    end

    it 'methods_of(...).allow() should return object of Privileges class' do
      Privileges.methods_of(Fixnum).allow_all.must_be_kind_of(Privileges)
    end

    it 'should chain one allow_method' do
      priv = Privileges.allow_method(:to_s)
      priv.allow?(Fixnum,4,:to_s,0).must_equal true
    end

    it 'should chain one allow_method and one allow_global' do
      priv = Privileges.
        allow_method(:to_s).
        allow_global_read(:$a)

      priv.allow?(Fixnum,4,:to_s,0).must_equal true
      priv.global_read_allowed?(:$a).must_equal true
    end

    # argument conversion
    it 'should allow + method (as string)' do
      priv = Privileges.new
      priv.allow_method('+')
      priv.allow?(Fixnum,4,:+,0).must_equal true
    end

    it 'should allow + method (as symbol)' do
      priv = Privileges.new
      priv.allow_method(:+)
      priv.allow?(Fixnum,4,:+,0).must_equal true
    end

    it 'should allow $a global read (as string)' do
      priv = Privileges.new
      priv.allow_global_read('$a')
      priv.global_read_allowed?(:$a).must_equal true
    end

    it 'should allow $a global read (as symbol)' do
      priv = Privileges.new
      priv.allow_global_read(:$a)
      priv.global_read_allowed?(:$a).must_equal true
    end

    it 'should allow multiple global read (as symbol) in only one allow_global_read call' do
      priv = Privileges.new
      priv.allow_global_read(:$a, :$b)
      priv.global_read_allowed?(:$a).must_equal true
      priv.global_read_allowed?(:$b).must_equal true
    end

    it 'should allow $a global write (as string)' do
      priv = Privileges.new
      priv.allow_global_write('$a')
      priv.global_write_allowed?(:$a).must_equal true
    end

    it 'should allow $a global write (as symbol)' do
      priv = Privileges.new
      priv.allow_global_write(:$a)
      priv.global_write_allowed?(:$a).must_equal true
    end

    it 'should allow multiple global write (as symbol) in only one allow_global_write call' do
      priv = Privileges.new
      priv.allow_global_write(:$a, :$b)
      priv.global_write_allowed?(:$a).must_equal true
      priv.global_write_allowed?(:$b).must_equal true
    end

    # constants

    it 'should allow constant read (as string)' do
      priv = Privileges.new
      priv.allow_const_read('TESTCONSTANT')
      priv.const_read_allowed?('TESTCONSTANT').must_equal true
    end

    it 'should allow constant read (as symbol)' do
      priv = Privileges.new
      priv.allow_const_read(:TESTCONSTANT)
      priv.const_read_allowed?('TESTCONSTANT').must_equal true
    end

    it 'should allow multiple constant read (as string) in only one allow_const_read call' do
      priv = Privileges.new
      priv.allow_const_read('TESTCONSTANT1', 'TESTCONSTANT2')
      priv.const_read_allowed?('TESTCONSTANT1').must_equal true
      priv.const_read_allowed?('TESTCONSTANT2').must_equal true
    end

    it 'should allow constant write (as string)' do
      priv = Privileges.new
      priv.allow_const_write('TESTCONSTANT')
      priv.const_write_allowed?('TESTCONSTANT').must_equal true
    end

    it 'should allow constant write (as symbol)' do
      priv = Privileges.new
      priv.allow_const_write(:TESTCONSTANT)
      priv.const_write_allowed?('TESTCONSTANT').must_equal true
    end

    it 'should allow multiple constant write (as symbol) in only one allow_const_write call' do
      priv = Privileges.new
      priv.allow_const_write('TESTCONSTANT1', 'TESTCONSTANT2')
      priv.const_write_allowed?('TESTCONSTANT1').must_equal true
      priv.const_write_allowed?('TESTCONSTANT2').must_equal true
    end
  end
end
