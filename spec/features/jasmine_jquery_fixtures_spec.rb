describe "Running a Jasmine jQuery Specs with Fixtures" do
  context 'without a browser through PhantomJS' do
    it 'runs the spec with 0 failures' do
      output = `cd ./spec/fixtures/jasmine-jquery-fixtures && ./../../../bin/ironboard --local`
      
      expect(output).to include('1 spec, 0 failures')
      expect(output).to_not include('1 failures')
    end
  end
end