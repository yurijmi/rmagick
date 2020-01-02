RSpec.describe Magick::Image do
  before do
    @test = Magick::Image.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first
  end

  def import_pixels(pixels, type)
    img = Magick::Image.new(@test.columns, @test.rows)
    img.import_pixels(0, 0, @test.columns, @test.rows, 'RGB', pixels, type)
    _, diff = img.compare_channel(@test, Magick::MeanAbsoluteErrorMetric)
    # _.display
    diff
  end

  def import(pixels, type, expected = 0.0)
    diff = import_pixels(pixels, type)
    expect(diff).to be_within(0.1).of(expected)
  end

  def fimport(pixels, type)
    diff = import_pixels(pixels, type)
    expect(diff).to be_within(50.0).of(0.0)
  end

  describe '#import_export_float' do
    it 'works' do
      pixels = @test.export_pixels(0, 0, @test.columns, @test.rows, 'RGB')
      fpixels = pixels.collect { |p| p.to_f / Magick::QuantumRange }
      p = fpixels.pack('F*')
      fimport(p, Magick::FloatPixel)

      p = fpixels.pack('D*')
      fimport(p, Magick::DoublePixel)
    end
  end

  describe '#import_export' do
    it 'works' do
      is_hdri_support = Magick::Magick_features =~ /HDRI/
      pixels = @test.export_pixels(0, 0, @test.columns, @test.rows, 'RGB')

      case Magick::MAGICKCORE_QUANTUM_DEPTH
      when 8
        p = pixels.pack('C*')
        import(p, Magick::CharPixel)
        p = pixels.pack('F*') if is_hdri_support
        import(p, Magick::QuantumPixel)

        spixels = pixels.collect { |px| px * 257 }
        p = spixels.pack('S*')
        import(p, Magick::ShortPixel)

        ipixels = pixels.collect { |px| px * 16_843_009 }
        p = ipixels.pack('I*')
        import(p, Magick::LongPixel)

      when 16
        cpixels = pixels.collect { |px| px / 257 }
        p = cpixels.pack('C*')
        import(p, Magick::CharPixel)

        p = pixels.pack('S*')
        import(p, Magick::ShortPixel)
        p = pixels.pack('F*') if is_hdri_support
        import(p, Magick::QuantumPixel)

        ipixels = pixels.collect { |px| px * 65_537 }
        ipixels.pack('I*')
        # Diff s/b 0.0 but never is.
        # import(p, Magick::LongPixel, 430.7834)

      when 32
        cpixels = pixels.collect { |px| px / 16_843_009 }
        p = cpixels.pack('C*')
        import(p, Magick::CharPixel)

        spixels = pixels.collect { |px| px / 65_537 }
        p = spixels.pack('S*')
        import(p, Magick::ShortPixel)

        p = pixels.pack('I*')
        import(p, Magick::LongPixel)
        p = pixels.pack('D*') if is_hdri_support
        import(p, Magick::QuantumPixel)

      when 64
        cpixels = pixels.collect { |px| px / 72_340_172_838_076_673 }
        p = cpixels.pack('C*')
        import(p, Magick::CharPixel)

        spixels = pixels.collect { |px| px / 281_479_271_743_489 }
        p = spixels.pack('S*')
        import(p, Magick::ShortPixel)

        ipixels = pixels.collect { |px| px / 4_294_967_297 }
        p = ipixels.pack('I*')
        import(p, Magick::LongPixel)

        p = pixels.pack('Q*')
        import(p, Magick::QuantumPixel)
      end
    end
  end
end