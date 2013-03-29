Meme.all.each do |m|
  if File.exists?("#{Meme::MEMES_DIR}/#{m.uid}.jpg")
    puts "Storing file #{Meme::MEMES_DIR}/#{m.uid}.jpg in db"
    image = Magick::Image.from_blob(File.read("#{Meme::MEMES_DIR}/#{m.uid}.jpg")).first
    image.format = "JPG"
    m.update_column(:picture, image.to_blob)
    FileUtils.rm("#{Meme::MEMES_DIR}/#{m.uid}.jpg") if ARGV[0] == 'delete'
  end
end