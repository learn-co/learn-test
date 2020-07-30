describe "Running a Pytest Unit Test" do
  context "a basic pytest unit test" do
    it "runs the spec with 0 failures" do
      output = `cd ./spec/fixtures/pytest-unit-spec && ./../../../bin/learn-test --local --test`

      expect(output).to include("2 passed")
      expect(output).to_not include("1 failed")
    end
  end
end