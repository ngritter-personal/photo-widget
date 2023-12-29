# app/controllers/static_pages_controller.rb

class StaticPagesController < ApplicationController
  def home
  end

  def show
    @photostream_url = params[:photostream_url]
    @photos = fetch_photos(@photostream_url)
  end

  private

  def fetch_photos(photostream_url)
    # Extract user ID from the photostream URL
    user_id = extract_user_id(photostream_url)

    if user_id.present?
      # Configure FlickRaw gem with your API key and secret
      flickr_api_key = ENV['FLICKR_API_KEY']
      flickr_shared_secret = ENV['FLICKR_API_SECRET']

      FlickRaw.api_key = flickr_api_key
      FlickRaw.shared_secret = flickr_shared_secret

      begin
        # Retrieve photos for the user
        photos = flickr.people.getPhotos(user_id: user_id)

        # Extract relevant details for each photo
        @photos = photos.map do |photo|
          {
            title: photo.title,
            url: FlickRaw.url(photo) # Adjust the size based on your requirements
            # Add more details as needed
          }
        end
      rescue FlickRaw::FailedResponse => e
        # Log the error
        Rails.logger.error("Flickr API error: #{e.message}")

        # Handle failed response from Flickr API
        # For example, you might want to log an error or display a user-friendly message
        @photos = []

        # Redirect to the home page with an error flash message
        redirect_to root_path, flash: { error: "User not found on Flickr" }
      end
    else
      # Redirect to the home page with an error flash message
      redirect_to root_path, flash: { error: "Invalid photostream URL" }
    end
  end

  def extract_user_id(photostream_url)
    # Extract user ID from the photostream URL
    # You may need to customize this based on the actual structure of the URL
    # For example, if the URL is like https://www.flickr.com/photos/123456789@N01/
    # then the user ID is '123456789@N01'
    # Extract the user ID using a regular expression or other parsing method
    # This is just a placeholder, adjust it according to the actual URL structure
    match = photostream_url.match(%r{photos/([^/]+)/?$})
    match[1] if match
  end
end