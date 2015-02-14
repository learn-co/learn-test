require_relative '../lib/dog'

describe Dog do
  it 'runs the spec spec correctly' do
    expect(subject).to be_an_instance_of(Dog)
  end
end