module LearnTest
  module Dependencies
    class Imagemagick < LearnTest::Dependency
      def missing?
        convert = `which convert`
        convert.empty? || convert.match(/not found/i)
      end

      def install
        brew = `which brew`

        if brew.empty? || brew.match(/not found/i)
          die('Please install ImageMagick'.red)
        else
          print_installing('ImageMagick')
          run_install('brew install imagemagick')
        end
      end
    end
  end
end
