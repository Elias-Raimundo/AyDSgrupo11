FROM ruby:3.2.2

RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && bundle install

RUN rm -f /app/config

COPY . .

EXPOSE 8000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]

