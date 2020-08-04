# frozen_string_literal: true

module LearnTest
  module Dependencies
    class Imagemagick < LearnTest::Dependency
      def missing?
        if win?
          convert = `where convert`
        else
          convert = `which convert`
        end

        convert.empty? || convert.match(/not found/i)
      end

      def install
        if win?
          brew = false
        else
          brew = `which brew`
        end

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
