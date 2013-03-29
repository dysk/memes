Meme.all.each do |m|
  if File.exists?("#{Meme::MEMES_DIR}/#{m.uid}.jpg")
    puts "Storing file #{Meme::MEMES_DIR}/#{m.uid}.jpg in db"
    m.update_column(:picture, File.read("#{Meme::MEMES_DIR}/#{m.uid}.jpg"))
    FileUtils.rm("#{Meme::MEMES_DIR}/#{m.uid}.jpg") if ARGV[0] == 'delete'
  end
end