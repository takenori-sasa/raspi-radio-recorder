FROM ruby:3.1

ENV LANG C.UTF-8
RUN mkdir /app
WORKDIR /app
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ffmpeg \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
