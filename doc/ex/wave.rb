require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first

img = img.wave

img.write('wave.jpg')
exit
