SETTINGS = YAML.load_file("#{::Rails.root.to_s}/config/settings.yml")[::Rails.env.to_s]
