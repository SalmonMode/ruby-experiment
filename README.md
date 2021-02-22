## Setup

### Prerequisites

* Ruby 2.6 (guide [here](http://watir.com/guides/ruby/))
* bundler (`gem install bundler`)
* Docker

### Dependency installation

```sh
bundle install
```

### Docker container for browser

```sh
docker run -d -p 4444:4444 -p 5900:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome-debug
```

Other images can be used. This one provides a VNC server (on port `5900`) though so it can be seen in action.

## Usage

```sh
ruby lib/main.rb <username> '<password>'
```
