# Apex Financial CRM

Apex Financial CRM is a multi-tenant client relationship management system built on **Ruby on Rails 8.1.3** and **Ruby 3.3.8**. It uses a Domain-Driven Design (DDD) layout to isolate core business rules and includes a real-time data integrity and compliance auditing system.

For a detailed breakdown of the application architecture, data schemas, domain models, and multi-tenancy patterns, refer to the [DEVELOPER_GUIDE.md](file:///c:/Users/johns/DEV/ruby-crm/DEVELOPER_GUIDE.md).

---

## 1. Prerequisites

Ensure you have the following installed on your local environment:
* **Ruby**: `3.3.8` (managed via `rbenv`, `rvm`, or `asdf` as specified in [.ruby-version](file:///c:/Users/johns/DEV/ruby-crm/.ruby-version))
* **Database**: **MySQL** (version 5.7+ or 8.0+)
* **Package Manager**: **Bundler** (`gem install bundler`)
* **Node.js / CSS compiler**: Required if compiling assets locally or modifying Tailwind styles.

---

## 2. Setup Instructions

Follow these steps to get the application up and running locally:

### Step 1: Install Dependencies
Install all required gems specified in the [Gemfile](file:///c:/Users/johns/DEV/ruby-crm/Gemfile):
```bash
bundle install
```

### Step 2: Configure Database
Open [config/database.yml](file:///c:/Users/johns/DEV/ruby-crm/config/database.yml) and verify your MySQL connection settings (username, password, and host). By default, the app expects:
* Host: `127.0.0.1` (or your local database socket)
* User: `root`
* Password: (empty)

If you need to supply credentials or point to a custom host, you can set the `DB_HOST` environment variable or edit the config file directly.

### Step 3: Create, Migrate, and Seed Database
Run the setup command to initialize the development and test databases, apply migrations, and seed a realistic financial advisory dataset:
```bash
bin/rails db:setup
```
*Alternatively, you can run the commands individually:*
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

The database seeding process creates:
* A sample firm: **Apex Wealth Advisors**
* Sample users (Sarah Jenkins & Marcus Brody)
* Multiple households, contacts, relationships, accounts, and active holdings.
* Structured compliance audit trails showing system activity history.
* Intentional data integrity violations (e.g. AUM drift, orphaned accounts) to demonstrate the Admin Dashboard's real-time audit tools.

---

## 3. Running the Application

To start the Rails server and live asset compiler, use the development wrapper:
```bash
bin/dev
```
This launches:
* **Puma web server** listening at [http://localhost:3000](http://localhost:3000)
* **Tailwind CSS compilation** process for admin dashboard style updates.

---

## 4. Viewing the Admin Dashboard

The application features a web-based **Database Integrity Check** panel.
* **URL**: [http://localhost:3000/admin](http://localhost:3000/admin)
* **Description**: This dashboard queries database relationships in real-time to locate orphaned accounts, households without primary members, stale asset holdings, and drift between denormalized values and actual sub-balances.
* **Authentication**: In development mode, the controller falls back to the seed database's first user automatically. In production, headers `X-Firm-Id` and `X-User-Id` must be supplied.

---

## 5. REST API Usage & Tenancy Context

All resources under `/api/v1/` require tenant context. Provide the following HTTP headers with your requests:
* `X-Firm-Id`: The unique ID of the firm (e.g. `1` for the seeded firm).
* `X-User-Id`: The ID of the authenticated user (e.g. `1` for Sarah Jenkins).

### Example cURL Request:
```bash
curl -X GET http://localhost:3000/api/v1/contacts \
  -H "X-Firm-Id: 1" \
  -H "X-User-Id: 1"
```

*Note: In `development` or `test` environments, the API automatically falls back to `Firm.first` and `User.first` if these headers are missing, allowing easy browser navigation.*

---

## 6. Running the Test Suite

The application uses **Minitest** for database model validation, domain service flows, and controller integration testing.

### Running under WSL (Recommended)
Since the Ruby environment is configured inside Windows Subsystem for Linux (WSL), execute commands using the `wsl` prefix and the full path to `bundle`:
* **Prepare the Test Database**:
  ```bash
  wsl /home/brent/.local/share/gem/ruby/3.3.0/bin/bundle exec rails db:test:prepare
  ```
* **Run all Tests**:
  ```bash
  wsl /home/brent/.local/share/gem/ruby/3.3.0/bin/bundle exec rails test
  ```

> [!WARNING]
> **Windows File Association Pop-up**: If you run `bin/rails` directly from Windows cmd/powershell, Windows will treat the extensionless `bin/rails` as a document and trigger an "Open with..." program selection pop-up. Always prefix commands with `wsl` or execute them directly inside a WSL bash shell.

---

## 7. Code Quality & Linting

Before pushing changes, run the code quality and security analysis suites:

* **Security Vulnerabilities Audit**:
  ```bash
  wsl /home/brent/.local/share/gem/ruby/3.3.0/bin/bundle exec brakeman
  wsl /home/brent/.local/share/gem/ruby/3.3.0/bin/bundle exec bundler-audit
  ```
* **Ruby Style Guide & Linter**:
  ```bash
  wsl /home/brent/.local/share/gem/ruby/3.3.0/bin/bundle exec rubocop
  ```

