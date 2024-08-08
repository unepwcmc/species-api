# Species+/CITES Checklist API

### Getting started

Ensure you already have Species+ installed and the database set up and running
on `localhost:5432`. Species API will use the Species+ database.

### Running locally

Install the relevant versions of `ruby` and `bundler`. You may find other system
dependencies such as `libsodium-dev` and `libpq-dev` are required.

```
# Install gems
bundle

# Run the server on http://localhost:3011/
bundle exec rails s -p 3011
```

### Running tests

```
bundle exec rake test
```
