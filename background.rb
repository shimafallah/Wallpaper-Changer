require 'json' 
require 'fiddle/import'
require 'open-uri'
require 'net/http'
SPI_SETDESKWALLPAPER = 20
SPIF_UPDATEINIFILE = 0x1
SPIF_SENDWININICHANGE = 0x2
module User32
    # Extend this module to an importer
    extend Fiddle::Importer
    # Load 'user32' dynamic library into this importer
    dlload 'user32'
    # Set C aliases to this importer for further understanding of function signatures
    typealias 'UINT', 'unsigned int'
    typealias 'UINT', 'unsigned int'
    typealias 'PVOID', 'void*'
    typealias 'UINT', 'unsigned int'
    typealias 'HANDLE', 'void*' #uintptr_t
    # Import C functions from loaded libraries and set them as module functions
    # More Info : https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa
    extern 'int SystemParametersInfoA(UINT, UINT, PVOID, UINT)'
end
def getWallpaper()
    clientId = 'Your Client ID'
    url = 'https://api.unsplash.com/photos/random/?client_id=' + clientId
    response = Net::HTTP.get_response(URI.parse(url))
    data = response.body
    result = JSON.parse(data)
    image = result['urls']['raw'] # You can use "full" , "regular" or "small" instead of "raw" for image quality
    wallpaper_path = ENV['HOME']+'/Pictures/'
    open(wallpaper_path + 'wallpaper.jpg', 'wb') do |file|
        file << open(image).read
    end
    User32::SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, wallpaper_path + 'wallpaper.jpg' , SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE)
    puts 'Wallpaper Changed Succesfully !'
    sleep(45 * 60) # Time By Secondes (default: 45min)
    getWallpaper()
end 
getWallpaper()
