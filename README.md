# Dino

Dino is a framework for HTTP services built on top of [Sinatra](http://sinatrarb.com/). It provides a number of common behaviors for encoding and decoding JSON request and response entities, building responses based on HTTP method, and returning appropriate responses for exceptions thrown by the service.

Dino integrates with [Mongoid](http://mongoid.org/) to load that framework's environment at startup and handle its specific exceptions as well.

As Sinatra is named for a member for the Chairman of the Board, so is Dino named after the King of Cool.

## Usage

    require 'dino/base'
    require 'dino/mongoid'

    class SongService < Dino::Base
      set :root, File.join(File.dirname(__FILE__), '..', '..')

      # requires settings.root to be set
      include Dino::MongoidApp

      # returns 200 with JSON-encoded array of songs
      get '/songs' do
        do_get do
          Song.all
        end
      end

      # returns 204, or 404 if the song doesn't exist
      delete '/songs/:id' do
        do_delete do
          song = Song.find(params[:id])
          raise Dino::NotFound unless song
          song.destroy
        end
      end
    end

## To do

* Gracefully handle database unavailability
* Caching
* POST and PUT respond with 204 and Content-Location
* Acceptable request media type validation

# Contributors

Since the git history was compacted, the awesome people responsible for this
codebase are listed below:

* [Brian Moseley](http://github.com/bcm)
* [Cutter Brown](http://github.com/cutter)
* [David LaMacchia](http://github.com/dlamacchia)
* [Ken Chong](http://github.com/kenchong)
* [Rob Zuber](http://github.com/z00b)
* [Travis Vachon](http://github.com/travis)
* [Zhihao Jia](http://github.com/zhihaojia)
