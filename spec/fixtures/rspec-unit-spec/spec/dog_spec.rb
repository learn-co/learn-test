require_relative '../lib/dog'

describe Dog do
  it 'runs the spec spec correctly' do
    expect(subject).to be_an_instance_of(Dog)
  end

  it 'has multiple specs' do
    expect(subject).not_to be_an_instance_of(String)
  end
end