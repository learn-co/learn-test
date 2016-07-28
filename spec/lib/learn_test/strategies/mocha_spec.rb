describe LearnTest::Strategies::Mocha do
  describe '#missing_dependencies?' do
    let(:package) do
      {
        dependencies: {
          dep1: "",
          dep2: ""
        },
        devDependencies: {
          devDep1: "",
          devDep2: ""
        },
        peerDependencies: {
          peerDep1: "",
          peerDep2: ""
        }
      }
    end
    let(:runner) { double("Runner", options: {}) }
    let(:strategy) { LearnTest::Strategies::Mocha.new(runner) }

    it "returns true if no node_modules directory" do
      expect(File).to receive(:exists?).with("node_modules") { false }

      expect(strategy.missing_dependencies?(package)).to eq(true)
    end

    context "node_modules exists" do
      before(:each) do
        allow(File).to receive(:exists?) { true }
      end

      it "returns true if missing a dependency" do
        expect(File).to receive(:exists?).with("node_modules/dep1") { true }
        expect(File).to receive(:exists?).with("node_modules/dep2") { false }
        expect(strategy.missing_dependencies?(package)).to eq(true)
      end

      it "returns true if missing a devDependency" do
        expect(File).to receive(:exists?).with("node_modules/devDep1") { true }
        expect(File).to receive(:exists?).with("node_modules/devDep2") { false }
        expect(strategy.missing_dependencies?(package)).to eq(true)
      end

      it "returns true if missing a peerDependency" do
        expect(File).to receive(:exists?).with("node_modules/peerDep1") { true }
        expect(File).to receive(:exists?).with("node_modules/peerDep2") { false }
        expect(strategy.missing_dependencies?(package)).to eq(true)
      end

      it "returns false if missing no dependencies" do
        expect(strategy.missing_dependencies?(package)).to eq(false)
      end

      it "returns false if there are no dependencies" do
        expect(strategy.missing_dependencies?({})).to eq(false)
      end
    end
  end
end
