describe "Running a RSpec Unit Test" do
  context 'a basic rspec unit test' do
    it 'runs the spec with 0 failures' do
      output = `cd ./spec/fixtures/rspec-unit-spec && ./../../../bin/learn-test --local --test`

      expect(output).to include('1 example, 0 failures')
      expect(output).to_not include('1 failures')
    end
  end
end
