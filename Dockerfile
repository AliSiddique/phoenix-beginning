FROM elixir:1.9.1-alpine 

# Install build dependencies
RUN apk add --update git build-base nodejs npm yarn python

# Prepare working directory

RUN mkdir /app

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Elixir Deps
COPY mix.exs mix.lock ./
RUN mix deps.get

# Install Node Deps
COPY assets/package.json assets/package-lock.json ./assets/

RUN cd assets && \
    npm install

# Copy over the rest of the app
COPY . .

# Compile assets
RUN cd assets && \
    npm run deploy && \
    cd .. && \
    mix phx.digest

# Compile the project
RUN mix do compile

# Run the phoenix server
CMD ["mix", "phx.server"]


