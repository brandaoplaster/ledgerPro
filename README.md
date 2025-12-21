# ledgerPro

A full-stack Ruby on Rails application to manage an investment wallet for stocks, REITs (FIIs), and cryptocurrencies.

The project uses Hotwire and Stimulus for a reactive UI and follows SOLID principles and Clean Code practices.

## What is this project?

ledgerPro is a portfolio manager where users can:
- Create an investment wallet
- Add assets (stocks, FIIs, crypto)
- Track current positions
- Register buy and sell operations
- Visualize data in real time using Hotwire

The goal is to provide a clean, maintainable codebase while delivering a modern full-stack Rails experience.

## Tech Stack

- Ruby 3.4.5
- Rails 8.1.1
- Hotwire (Turbo + Stimulus)
- Importmaps (no Node.js)
- PostgreSQL
- Docker & Docker Compose (development)

## Code Quality

This project is built with:
- SOLID principles
- Clean Code practices
- Service objects and POROs where needed
- Small, focused classes and methods
- High test coverage

## Requirements

You only need:
- Docker
- Docker Compose

No local Ruby, Rails, Node, or database required.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/brandaoplaster/ledgerPro.git
cd ledgerPro
````

Build and start containers:

```bash
docker compose up --build
```

Setup the database:

```bash
docker compose run ledger bundle exec rails db:create db:migrate
```

Open in browser:

```
http://localhost:3000
```

## Useful Commands

Rails console:

```bash
docker compose run ledger bundle exec rails c
```

Run tests:

```bash
docker compose run ledger bundle exec rails test
```

Stop containers:

```bash
docker compose down
```

## Project Structure

```
.
├── app/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   ├── views/
│   └── javascript/ (Stimulus)
├── config/
├── db/
├── Dockerfile
├── compose.yml
└── README.md
```

## License
