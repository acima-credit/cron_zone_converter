# frozen_string_literal: true

RSpec.describe CronZoneConverter do
  it 'has a version number' do
    expect(CronZoneConverter::VERSION).not_to be nil
  end

  describe '#convert' do
    context 'invalid' do
      let(:klass) { described_class::Error }
      context 'line', :utc do
        let(:message) { 'invalid cron line' }
        it('nil    ') { expect { described_class.convert(nil) }.to raise_error(klass, message) }
        it('empty  ') { expect { described_class.convert('') }.to raise_error(klass, message) }
        it('invalid') { expect { described_class.convert(nil) }.to raise_error(klass, message) }
        it('wrong  ') { expect { described_class.convert(123) }.to raise_error(klass, message) }
      end
      context 'zone', :none do
        let(:message) { 'missing zone' }
        it('nil    ') { expect { described_class.convert('* * * * *', nil) }.to raise_error(klass, 'missing zone') }
        it('invalid') { expect { described_class.convert('* * * * *', 'UNK') }.to raise_error(klass, 'invalid zone') }
      end
    end
    context 'zones' do
      context 'UTC / UTC', :utc do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5')).to eq(['0 * 5,10 * 1-5'])
          end
          it 'step-only hours' do
            expect(described_class.convert('0 * */4 * 1-5')).to eq(['0 * */4 * 1-5'])
          end
          context 'same day' do
            it 'single hour' do
              expect(described_class.convert('0 12 * * 1-5')).to eq(['0 12 * * 1-5'])
            end
            it 'multiple hours' do
              expect(described_class.convert('0 12,13 * * 1-5')).to eq(['0 12,13 * * 1-5'])
            end
          end
        end
      end
      context 'MDT / UTC', :mdt do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 12 * * 1-5')).to eq(['0 18 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 12,13 * * 1-5')).to eq(['0 18,19 * * 1,2,3,4,5'])
          end
          it 'step and single hour' do
            expect(described_class.convert('0 */12,13 * * 1-5')).to eq(['0 6,18,19 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 20 * * 1-5')).to eq(['0 2 * * 2,3,4,5,6'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 20,21 * * 1-5')).to eq(['0 2,3 * * 2,3,4,5,6'])
          end
        end
        context 'mixed days' do
          it 'multiple hours' do
            expect(described_class.convert('0 16,20 * * 1-5')).to eq(['0 2 * * 2,3,4,5,6', '0 22 * * 1,2,3,4,5'])
          end
        end
      end
      context 'MST / UTC', :mst do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 12 * * 1-5')).to eq(['0 19 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 12,13 * * 1-5')).to eq(['0 19,20 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 20 * * 1-5')).to eq(['0 3 * * 2,3,4,5,6'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 20,21 * * 1-5')).to eq(['0 3,4 * * 2,3,4,5,6'])
          end
        end
        context 'mixed days' do
          it 'multiple hours' do
            expect(described_class.convert('0 16,20 * * 1-5')).to eq(['0 23 * * 1,2,3,4,5', '0 3 * * 2,3,4,5,6'])
          end
        end
      end
      context 'Hanoi / UTC', :han do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 12 * * 1-5')).to eq(['0 5 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 12,13 * * 1-5')).to eq(['0 5,6 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 3 * * 1-5')).to eq(['0 20 * * 0,1,2,3,4'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 3,4 * * 1-5')).to eq(['0 20,21 * * 0,1,2,3,4'])
          end
        end
        context 'mixed days' do
          it 'multiple hours' do
            expect(described_class.convert('0 5,12 * * 1-5')).to eq(['0 22 * * 0,1,2,3,4', '0 5 * * 1,2,3,4,5'])
          end
        end
      end
      context 'MST / EST', :mst do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *', 'MST', 'EST')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5', 'MST', 'EST')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 3 * * 1-5', 'MST', 'EST')).to eq(['0 5 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 3,4 * * 1-5', 'MST', 'EST')).to eq(['0 5,6 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 23 * * 1-5', 'MST', 'EST')).to eq(['0 1 * * 2,3,4,5,6'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 22,23 * * 1-5', 'MST', 'EST')).to eq(['0 0,1 * * 2,3,4,5,6'])
          end
        end
        context 'mixed days' do
          context 'with weekdays' do
            it 'multiple hours' do
              expect(described_class.convert('0 16,22 * * 1-5', 'MST', 'EST')).to eq(['0 0 * * 2,3,4,5,6', '0 18 * * 1,2,3,4,5'])
            end
          end
          context 'with month days' do
            it 'multiple hours' do
              expect(described_class.convert('0 16,22 5,10 * *', 'MST', 'EST')).to eq(['0 0 6,11 * *', '0 18 5,10 * *'])
            end
          end
          context 'with weekdays and month' do
            it 'multiple hours' do
              expect(described_class.convert('0 16,22 5,10 * 1-5', 'MST', 'EST')).to eq(['0 0 6,11 * 2,3,4,5,6', '0 18 5,10 * 1,2,3,4,5'])
            end
          end
        end
      end
      context 'MST / Hanoi', :mst do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *', 'MST', 'Hanoi')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5', 'MST', 'Hanoi')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 3 * * 1-5', 'MST', 'Hanoi')).to eq(['0 17 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 3,4 * * 1-5', 'MST', 'Hanoi')).to eq(['0 17,18 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 13 * * 1-5', 'MST', 'Hanoi')).to eq(['0 3 * * 2,3,4,5,6'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 13,14 * * 1-5', 'MST', 'Hanoi')).to eq(['0 3,4 * * 2,3,4,5,6'])
          end
        end
        context 'mixed days' do
          it 'multiple hours' do
            expect(described_class.convert('0 5,12 * * 1-5', 'MST', 'Hanoi')).to eq(['0 19 * * 1,2,3,4,5', '0 2 * * 2,3,4,5,6'])
          end
        end
      end
      context 'Hanoi / MST', :han do
        context 'no changes needed' do
          it 'always' do
            expect(described_class.convert('* * * * *', 'Hanoi', 'MST')).to eq(['* * * * *'])
          end
          it 'no hours' do
            expect(described_class.convert('0 * 5,10 * 1-5', 'Hanoi', 'MST')).to eq(['0 * 5,10 * 1-5'])
          end
        end
        context 'same day' do
          it 'single hour' do
            expect(described_class.convert('0 18 * * 1-5', 'Hanoi', 'MST')).to eq(['0 4 * * 1,2,3,4,5'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 18,19 * * 1-5', 'Hanoi', 'MST')).to eq(['0 4,5 * * 1,2,3,4,5'])
          end
        end
        context 'different day' do
          it 'single hour', :focus do
            expect(described_class.convert('0 3 * * 1-5', 'Hanoi', 'MST')).to eq(['0 13 * * 0,1,2,3,4'])
          end
          it 'multiple hours' do
            expect(described_class.convert('0 3,4 * * 1-5', 'Hanoi', 'MST')).to eq(['0 13,14 * * 0,1,2,3,4'])
          end
        end
        context 'mixed days' do
          it 'multiple hours' do
            expect(described_class.convert('0 12,18 * * 1-5', 'Hanoi', 'MST')).to eq(['0 22 * * 0,1,2,3,4', '0 4 * * 1,2,3,4,5'])
          end
        end
      end
    end
  end
end
