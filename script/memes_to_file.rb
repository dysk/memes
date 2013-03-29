Meme.all.each do |m|
  puts "Saving #{m.uid} meme to file #{Meme::MEMES_DIR}/#{m.uid}.jpg"
  File.open("#{Meme::MEMES_DIR}/#{m.uid}.jpg", 'w:ASCII-8BIT') {|f| f.write(m.picture) }
  m.update_column(:picture, nil)
end