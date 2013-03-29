Meme.all.each do |m|
  unless m.picture.nil?
    puts "Saving #{m.uid} meme to file #{Meme::MEMES_DIR}/#{m.uid}.jpg"
    File.open("#{Meme::MEMES_DIR}/#{m.uid}.jpg", 'w:ASCII-8BIT') {|f| f.write(m.picture) }
    m.update_column(:picture, nil) if ARGV[0] == 'delete'
  end
end