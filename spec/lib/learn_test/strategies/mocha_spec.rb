# frozen_string_literal: true

describe LearnTest::Strategies::Mocha do
  describe '#missing_dependencies?' do
    let(:package) do
      {
        dependencies: {
          dep1: '',
          dep2: ''
        },
        devDependencies: {
          devDep1: '',
          devDep2: ''
        },
        peerDependencies: {
          peerDep1: '',
          peerDep2: ''
        }
      }
    end

    let(:runner) { double('Runner', options: {}) }
    let(:strategy) { LearnTest::Strategies::Mocha.new(runner) }

    context 'node_modules/ does not exist' do
      it 'returns true' do
        allow(File).to receive(:exist?).with('node_modules').and_return(false)
        expect(strategy.missing_dependencies?).to eq(true)
      end
    end

    context 'node_modules/ exists' do
      before(:each) do
        allow(File).to receive(:exist?).and_return(true)
        allow(strategy).to receive(:js_package).and_return(package)
      end

      it 'returns true if missing a dependency' do
        allow(File).to receive(:exist?).with('node_modules/dep2').and_return(false)
        expect(strategy.missing_dependencies?).to eq(true)
      end

      it 'returns true if missing a devDependency' do
        allow(File).to receive(:exist?).with('node_modules/devDep2').and_return(false)
        expect(strategy.missing_dependencies?).to eq(true)
      end

      it 'returns true if missing a peerDependency' do
        allow(File).to receive(:exist?).with('node_modules/peerDep2').and_return(false)
        expect(strategy.missing_dependencies?).to eq(true)
      end

      it 'returns false if missing no dependencies' do
        allow(File).to receive(:exist?).and_return(true)
        expect(strategy.missing_dependencies?).to eq(false)
      end

      it 'returns false if there are no dependencies' do
        allow(strategy).to receive(:js_package).and_return({})
        expect(strategy.missing_dependencies?).to eq(false)
      end
    end
  end
end
