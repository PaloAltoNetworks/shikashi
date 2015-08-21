# Encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

include Shikashi

$top_level_binding = binding

describe Sandbox, 'Shikashi sandbox' do
  it 'should run empty code without privileges' do
    Sandbox.new.run ''
  end

  it 'should run empty code with privileges' do
    Sandbox.new.run '', Privileges.new
  end

  class X
    def foo
    end
  end
  it 'should raise SecurityError when call method without privileges' do

    x = X.new

    lambda {
      Sandbox.new.run 'x.foo', binding, :no_base_namespace => true
    }.must_raise(SecurityError)

  end

  it 'should not raise anything when call method with privileges' do

    x = X.new
    privileges = Privileges.new
    def privileges.allow?(*args)
      true
    end

    Sandbox.new.run 'x.foo', binding, :privileges => privileges, :no_base_namespace => true

  end


  module ::A4
    module B4
      module C4

      end
    end
  end

  it 'should allow use a class declared inside' do
    priv = Privileges.new
    priv.allow_method :new
    Sandbox.new.run('
      class ::TestInsideClass
        def foo
        end
      end

      ::TestInsideClass.new.foo
    ', priv)
  end

  it 'should use base namespace when the code uses colon3 node (2 levels)' do
    Sandbox.new.run( '::B4',
                     :base_namespace => A4
    ).must_equal A4::B4
  end

  it 'should change base namespace when classes are declared (2 levels)' do
    Sandbox.new.run( '
                class ::X4
                   def foo
                   end
                end
            ',
                     :base_namespace => A4
    )

    A4::X4
  end

  it 'should use base namespace when the code uses colon3 node (3 levels)' do
    Sandbox.new.run( '::C4',
                     $top_level_binding, :base_namespace => ::A4::B4
    ).must_equal ::A4::B4::C4
  end

  it 'should change base namespace when classes are declared (3 levels)' do
    Sandbox.new.run( '
                class ::X4
                   def foo
                   end
                end
            ',
                     $top_level_binding, :base_namespace => ::A4::B4
    )

    A4::B4::X4
  end

  it 'should reach local variables when current binding is used' do
    a = 5
    Sandbox.new.run('a', binding, :no_base_namespace => true).must_equal 5
  end

  class N
    def foo
      @a = 5
      Sandbox.new.run('@a', binding, :no_base_namespace => true)
    end
  end


  it 'should allow reference to instance variables' do
    N.new.foo.must_equal 5
  end

  it 'should create a default module for each sandbox' do
    s = Sandbox.new
    s.run('class X
              def foo
                 "foo inside sandbox"
              end
            end')

    x = s.base_namespace::X.new
    x.foo.must_equal 'foo inside sandbox'
  end

  it 'should not allow xstr when no authorized' do
    s = Sandbox.new
    priv = Privileges.new

    lambda {
      s.run('%x[echo hello world]', priv)
    }.must_raise(SecurityError)

  end

  it 'should allow xstr when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_xstr

    lambda {
      s.run('%x[echo hello world]', priv)
    }

  end

  it 'should not allow global variable read' do
    s = Sandbox.new
    priv = Privileges.new

    lambda {
      s.run('$a', priv)
    }.must_raise(SecurityError)
  end

  it 'should allow global variable read when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_global_read(:$a)

    lambda {
      s.run('$a', priv)
    }
  end

  it 'should not allow constant variable read' do
    s = Sandbox.new
    priv = Privileges.new

    TESTCONSTANT9999 = 9999
    lambda {
      s.run('TESTCONSTANT9999', priv)
    }.must_raise(SecurityError)
  end

  it 'should allow constant read when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_const_read('TESTCONSTANT9998')
    ::TESTCONSTANT9998 = 9998

    lambda {
      s.run('TESTCONSTANT9998', priv).must_equal 9998
    }
  end

  it 'should allow read constant nested on classes when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_const_read('Fixnum')
    Fixnum::TESTCONSTANT9997 = 9997

    lambda {
      s.run('Fixnum::TESTCONSTANT9997', priv).must_equal 9997
    }
  end


  it 'should not allow global variable write' do
    s = Sandbox.new
    priv = Privileges.new

    lambda {
      s.run('$a = 9', priv)
    }.must_raise(SecurityError)
  end

  it 'should allow global variable write when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_global_write(:$a)

    lambda {
      s.run('$a = 9', priv)
    }
  end

  it 'should not allow constant write' do
    s = Sandbox.new
    priv = Privileges.new

    lambda {
      s.run('TESTCONSTANT9999 = 99991', priv)
    }.must_raise(SecurityError)
  end

  it 'should allow constant write when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_const_write('TESTCONSTANT9998')

    lambda {
      s.run('TESTCONSTANT9998 = 99981', priv)
      TESTCONSTANT9998.must_equal 99981
    }
  end

  it 'should allow write constant nested on classes when authorized' do
    s = Sandbox.new
    priv = Privileges.new

    priv.allow_const_read('Fixnum')
    priv.allow_const_write('Fixnum::TESTCONSTANT9997')

    lambda {
      s.run('Fixnum::TESTCONSTANT9997 = 99971', priv)
      Fixnum::TESTCONSTANT9997.must_equal 99971
    }
  end

  it 'should allow package of code' do
    s = Sandbox.new

    lambda {
      s.packet('print "hello world\n"')
    }
  end

  def self.package_oracle(args1, args2)
    it 'should allow and execute package of code' do
      e1 = nil
      e2 = nil
      r1 = nil
      r2 = nil

      begin
        s = Sandbox.new
        r1 = s.run(*(args1+args2))
      rescue Exception => e
        e1 = e
      end

      begin
        s = Sandbox.new
        packet = s.packet(*args1)
        r2 = packet.run(*args2)
      rescue Exception => e
        e2 = e
      end

      e1.must_equal e2
      r1.must_equal r2
    end
  end

  class ::XPackage
    def foo

    end
  end

  package_oracle ['1'], [:binding => binding]
  package_oracle ['1+1',{ :privileges => Privileges.allow_method(:+)}], [:binding => binding]

  it 'should accept references to classes defined on previous run' do
    sandbox = Sandbox.new

    sandbox.run('class XinsideSandbox
    end')

    sandbox.run('XinsideSandbox').must_equal sandbox.base_namespace::XinsideSandbox
  end

  class OutsideX44
    def method_missing(name)
      name
    end
  end
  OutsideX44_ins = OutsideX44.new

  it 'should allow method_missing handling' do
    sandbox = Sandbox.new
    privileges = Privileges.new
    privileges.allow_const_read('OutsideX44_ins')
    privileges.instances_of(OutsideX44).allow :method_missing

    sandbox.run('OutsideX44_ins.foo', privileges).must_equal :foo
  end
end
