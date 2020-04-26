# Backup_Retention

A simple Ruby application that creates Volume snapshots for DigitalOcean Volumes mounted into Droplets.

The project includes a Dockerfile to build an Image that runs this program on a cron schedule to create dayily backups and retain them according to configuration.

## Installation

Get dependencies via

    $ bundle install

Or install it yourself as:

    $ gem install backup_retention

## Usage

The CLI is build with Thor, so running

    backup_retention help

will print all available commands. Note that a DigitalOcean "Personal Access Token" is required and can be supplied by either the CLI argument or environment variable.