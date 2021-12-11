# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::BlockForwarding, :config do
  context 'when `EnforcedStyle: anonymous' do
    let(:cop_config) { { 'EnforcedStyle' => 'anonymous' } }

    context 'Ruby >= 3.1', :ruby31 do
      it 'registers and corrects an offense when using explicit block forwarding' do
        expect_offense(<<~RUBY)
          def foo(&block)
                  ^^^^^^ Use anonymous block forwarding.
            bar(&block)
                ^^^^^^ Use anonymous block forwarding.
            baz(qux, &block)
                     ^^^^^^ Use anonymous block forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(&)
            bar(&)
            baz(qux, &)
          end
        RUBY
      end

      it 'registers and corrects an offense when using explicit block forwarding in singleton method' do
        expect_offense(<<~RUBY)
          def self.foo(&block)
                       ^^^^^^ Use anonymous block forwarding.
            self.bar(&block)
                     ^^^^^^ Use anonymous block forwarding.
            self.baz(qux, &block)
                          ^^^^^^ Use anonymous block forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo(&)
            self.bar(&)
            self.baz(qux, &)
          end
        RUBY
      end

      it 'registers and corrects an offense when using symbol proc argument in method body' do
        expect_offense(<<~RUBY)
          def foo(&block)
                  ^^^^^^ Use anonymous block forwarding.
            bar(&:do_something)
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(&)
            bar(&:do_something)
          end
        RUBY
      end

      it 'registers and corrects an offense when using `yield` in method body' do
        expect_offense(<<~RUBY)
          def foo(&block)
                  ^^^^^^ Use anonymous block forwarding.
            yield
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(&)
            yield
          end
        RUBY
      end

      it 'registers and corrects an offense when using explicit block forwarding without method body' do
        expect_offense(<<~RUBY)
          def foo(&block)
                  ^^^^^^ Use anonymous block forwarding.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(&)
          end
        RUBY
      end

      it 'does not register an offense when using anonymous block forwarding' do
        expect_no_offenses(<<~RUBY)
          def foo(&)
            bar(&)
          end
        RUBY
      end

      it 'does not register an offense when using anonymous block forwarding without method body' do
        expect_no_offenses(<<~RUBY)
          def foo(&)
          end
        RUBY
      end

      it 'does not register an offense when using block argument as a variable' do
        expect_no_offenses(<<~RUBY)
          def foo(&block)
            bar(&block) if block
          end

          def foo(&block)
            block.call
          end
        RUBY
      end

      it 'does not register an offense when defining without block argument method' do
        expect_no_offenses(<<~RUBY)
          def foo(arg1, arg2)
          end
        RUBY
      end

      it 'does not register an offense when defining kwarg with block args method' do
        # Prevents the following syntax error:
        #
        # % ruby -cve 'def foo(k:, &); bar(&); end'
        # ruby 3.1.0dev (2021-12-05T10:23:42Z master 19f037e452) [x86_64-darwin19]
        # -e:1: no anonymous block parameter
        #
        expect_no_offenses(<<~RUBY)
          def foo(k:, &block)
            bar(&block)
          end
        RUBY
      end

      it 'does not register an offense when defining kwoptarg with block args method' do
        # Prevents the following syntax error:
        #
        # % ruby -cve 'def foo(k: v, &); bar(&); end'
        # ruby 3.1.0dev (2021-12-05T10:23:42Z master 19f037e452) [x86_64-darwin19]
        # -e:1: no anonymous block parameter
        #
        expect_no_offenses(<<~RUBY)
          def foo(k: v, &block)
            bar(&block)
          end
        RUBY
      end

      it 'does not register an offense when defining no arguments method' do
        expect_no_offenses(<<~RUBY)
          def foo
          end
        RUBY
      end
    end

    context 'Ruby < 3.0', :ruby30 do
      it 'does not register an offense when not using anonymous block forwarding' do
        expect_no_offenses(<<~RUBY)
          def foo(&block)
            bar(&block)
          end
        RUBY
      end
    end
  end

  context 'when `EnforcedStyle: explicit' do
    let(:cop_config) { { 'EnforcedStyle' => 'explicit' } }

    context 'Ruby >= 3.1', :ruby31 do
      it 'registers an offense when using anonymous block forwarding' do
        expect_offense(<<~RUBY)
          def foo(&)
                  ^ Use explicit block forwarding.
            bar(&)
                ^ Use explicit block forwarding.
            baz(qux, &)
                     ^ Use explicit block forwarding.
          end
        RUBY
      end

      it 'registers an offense when using anonymous block forwarding in singleton method' do
        expect_offense(<<~RUBY)
          def self.foo(&)
                       ^ Use explicit block forwarding.
            self.bar(&)
                     ^ Use explicit block forwarding.
            self.baz(qux, &)
                          ^ Use explicit block forwarding.
          end
        RUBY
      end

      it 'registers an offense when using symbol proc argument in method body' do
        expect_offense(<<~RUBY)
          def foo(&)
                  ^ Use explicit block forwarding.
            bar(&:do_something)
          end
        RUBY
      end

      it 'registers an offense when using `yield` in method body' do
        expect_offense(<<~RUBY)
          def foo(&)
                  ^ Use explicit block forwarding.
            yield
          end
        RUBY
      end

      it 'registers and corrects an offense when using anonymous block forwarding without method body' do
        expect_offense(<<~RUBY)
          def foo(&)
                  ^ Use explicit block forwarding.
          end
        RUBY
      end

      it 'does not register an offense when using explicit block forwarding' do
        expect_no_offenses(<<~RUBY)
          def foo(&block)
            bar(&block)
          end
        RUBY
      end

      it 'does not register an offense when using explicit block forwarding without method body' do
        expect_no_offenses(<<~RUBY)
          def foo(&block)
          end
        RUBY
      end

      it 'does not register an offense when defining without block argument method' do
        expect_no_offenses(<<~RUBY)
          def foo(arg1, arg2)
          end
        RUBY
      end
    end
  end
end
