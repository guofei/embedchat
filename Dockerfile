FROM elixir
MAINTAINER kaku <kaku@kaku>

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl wget make gcc postgresql

RUN mix local.hex --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

RUN curl -sL https://deb.nodesource.com/setup_5.x | bash - && apt-get install -y nodejs

ENV PORT 80
ENV HOST lewini.com
ENV MIX_ENV prod
ENV SSL_KEY_PATH /myapp/ssl/private.key
ENV SSL_CERT_PATH /myapp/ssl/lewini_com.crt

RUN mkdir /myapp
WORKDIR /myapp
ADD config/prod.secret.exs /myapp/config/prod.secret.exs
ADD . /myapp
RUN mix deps.get && npm install && mix local.rebar
RUN npm run compile
RUN npm run phantomjs &
RUN mix compile
RUN mix phoenix.digest
# RUN mix release

# CMD ["/myapp/rel/embed_chat/bin/embed_chat", "foreground"]
CMD ["mix", "phoenix.server"]