# Lewini Live Chat

A growth hacking service that you can live chat with visitors on your website.

[www.lewini.com](http://www.lewini.com)

## Installation

Fill out secret keys and app paths.

Install Docker and run:
```
docker-compose build
docker-compose up -d
docker-compose run web mix ecto.create
docker-compose run web mix ecto.migrate
```

## License

[MIT](http://opensource.org/licenses/MIT)
