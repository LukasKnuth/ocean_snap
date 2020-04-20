# Mulit-stage build: Builder image
FROM ruby:2.7 AS builder

COPY . /app
WORKDIR /app
RUN bundler install && rake test && rake build

# Build the final Image
FROM ruby:2.7-alpine

COPY crontab /etc/crontab/crontab
# Initialize crontab with the file:
RUN crontab /etc/crontab/crontab

COPY --from=builder /app/pkg/*.gem /installer/
RUN gem install /installer/*.gem

ENTRYPOINT ["crond"]
# Run cron in the foreground and block so the container stays up.
# Also make crontab output all stdout and stderr from commands so that "docker log" picks it up
# See https://stackoverflow.com/a/60816190/717341
CMD ["-f", "-l", "2"]