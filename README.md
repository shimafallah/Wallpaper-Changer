# Wallpaper-Changer

This Ruby script fetches a random wallpaper from Unsplash and sets it as your desktop wallpaper periodically.

## Getting Started
#### Prerequisites
-   Ruby installed on your system
-   Internet connection

### Installation
1. **Clone the repository** (or download the script directly):
2. **Install required Ruby gems**:

```
gem install json fiddle open-uri net-http
```

## Unsplash API Access

To use the Unsplash API, you need to obtain a `client_id`. Follow these steps:

1. **Sign Up/Login to Unsplash**:

-   If you don't already have an account, go to [Unsplash](https://unsplash.com/) and sign up.
-   If you already have an account, log in.

2. **Register as a Developer**:
- Go to the Unsplash Developer section at Unsplash Developers.

3. **Create a New Application**:
-   Click on "Your Apps" in the top-right menu.
-   Click the "New Application" button.
-   Fill out the required information for your new application. This includes the application name, description, and your usage plan.
-   Agree to the terms and create the application.
4. **Get the `client_id`**:
-   Once the application is created, you'll be redirected to the application details page.
-   On this page, you'll find your `Access Key` and `Secret Key`. The `Access Key` is your `client_id`.

### Configuration
Replace `'your_actual_access_key'` in the script with your actual `Access Key` from Unsplash.

### Running the Script
Run the script using Ruby:
```
ruby background.rb
```

## Script Overview

The provided Ruby script performs the following tasks:

1.  **Fetch a random wallpaper URL** from Unsplash using the provided `client_id`.
2.  **Download the wallpaper** to a local directory (`~/Pictures/`).
3.  **Set the downloaded image** as the desktop wallpaper using Windows API.
4.  **Repeat the process** every 45 minutes (configurable).

### Key Components
**Fetching Wallpaper URL**:
```ruby
def fetch_wallpaper_url(client_id)
  url = "https://api.unsplash.com/photos/random/?client_id=#{client_id}"
  response = Net::HTTP.get_response(URI.parse(url))

  if response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    return data['urls']['raw']
  else
    raise "Failed to fetch wallpaper: #{response.message}"
  end
end
```
**Downloading the Image**:
```ruby
def download_image(url, path)
  open(path, 'wb') do |file|
    file << open(url).read
  end
end
```

**Setting the Wallpaper**:
```ruby
def set_wallpaper(image_path)
  User32::SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, image_path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE)
end
```
**Changing Wallpaper Periodically**:
```ruby
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
```
### Running the Script
The script starts by calling `change_wallpaper_periodically` with the specified `client_id` and interval (default is 45 minutes):
```ruby
client_id = 'your_actual_access_key' # Replace with your actual Access Key from Unsplash
interval_in_seconds = 45 * 60
change_wallpaper_periodically(client_id, interval_in_seconds)
```


