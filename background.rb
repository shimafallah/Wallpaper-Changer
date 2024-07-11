require 'json'
require 'fiddle/import'
require 'open-uri'
require 'net/http'

SPI_SETDESKWALLPAPER = 20
SPIF_UPDATEINIFILE = 0x1
SPIF_SENDWININICHANGE = 0x2

module User32
  extend Fiddle::Importer
  dlload 'user32'
  typealias 'UINT', 'unsigned int'
  typealias 'PVOID', 'void*'
  extern 'int SystemParametersInfoA(UINT, UINT, PVOID, UINT)'
end

def fetch_wallpaper_url(client_id)
  url = "https://api.unsplash.com/photos/random/?client_id=#{client_id}"
  response = Net::HTTP.get_response(URI.parse(url))

  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    return data['urls']['raw'] # Use "full", "regular" or "small" for different image qualities
  else
    raise "Failed to fetch wallpaper: #{response.message}"
  end
end

def download_image(url, path)
  open(path, 'wb') do |file|
    file << open(url).read
  end
end

def set_wallpaper(image_path)
  User32::SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, image_path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE)
end

def change_wallpaper_periodically(client_id, interval)
  loop do
    begin
      wallpaper_url = fetch_wallpaper_url(client_id)
      wallpaper_path = File.join(ENV['HOME'], 'Pictures', 'wallpaper.jpg')
      download_image(wallpaper_url, wallpaper_path)
      set_wallpaper(wallpaper_path)
      puts 'Wallpaper changed successfully!'
    rescue => e
      puts "Error: #{e.message}"
    end

    sleep(interval)
  end
end

client_id = 'Your_Client_ID'
interval_in_seconds = 45 * 60
change_wallpaper_periodically(client_id, interval_in_seconds)

