FROM ruby:3.2-alpine

# Install dependencies (Alpine Linux packages)
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm

WORKDIR /site

# Copy Gemfile first for better caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy site content
COPY . .

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "--force_polling", "--host", "0.0.0.0", "--livereload"]
