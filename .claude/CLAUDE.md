# Rails projecten – Canonieke referentie: Fizzy

Bij elk Rails project dat ik aan werk geldt: **Fizzy (`~/code/fizzy`) is de referentie-implementatie.**
Bij elke architectuurvraag of implementatiekeuze: kijk eerst hoe Fizzy het oplost en volg dat patroon.

## Vaste antwoorden op terugkerende Rails vragen

| Vraag | Fizzy-antwoord |
|-------|---------------|
| Database primaire sleutels | UUIDv7 binary(16), zie `config/initializers/uuid_primary_keys.rb` |
| Authenticatie | Passwordless magic links (`Identity` + `MagicLink` model) |
| Autorisatie | Role-based (`User#role`) + expliciete `Access` records per resource |
| Multi-tenancy | URL-pad middleware (`AccountSlug::Extractor`), `Current.account` |
| Background jobs | Solid Queue (geen Redis), account context via GlobalID serialization |
| Secrets/credentials | Kamal `.kamal/secrets` + ENV vars. Nooit hardcoded, nooit in git |
| Frontend JS | Importmap + Turbo + Stimulus. Geen webpack, vite, of node build step |
| CSS/assets | Propshaft. Geen Sprockets, geen Webpacker |
| Real-time updates | Turbo Streams + Action Cable (Solid Cable adapter) |
| Zoekfunctie | Sharded MySQL full-text search (geen Elasticsearch) |
| E-mail in development | letter_opener |
| Deployment | Kamal (Docker containers, geen Kubernetes) |
| Testing | Minitest + fixtures (geen RSpec, geen FactoryBot) |
| Database in development | SQLite; productie MySQL via Trilogy adapter |
| Job monitoring | Mission Control::Jobs (`/admin/jobs`) |
| Paginering | geared_pagination |

## Coding conventions (uit Fizzy STYLE.md)

- **Conditionals**: Expanded `if/else` boven guard clauses. Guard clauses alleen aan het begin van een methode als de body complex is.
- **Methode volgorde**: `class` methoden → `public` (initialize eerst) → `private`
- **Invocation order**: Methoden verticaal in volgorde van aanroep
- **Bang methods**: `!` alleen als non-bang tegenhanger bestaat
- **Controllers**: CRUD only — geen custom actions, maak een nieuwe resource
- **Model/controller**: Thin controllers met rijke domain models. Geen services tenzij echt nodig.
- **Jobs**: Delegeer logica aan model methoden. Gebruik `_later` / `_now` suffix.
- **Concerns**: Zware gebruik van concerns voor model compositie (20+ per model is normaal)
- **Visibility**: Geen newline na `private`, wél indentering van private methoden

## Referentiebestanden in Fizzy

Bij twijfel over implementatie, lees het overeenkomstige bestand in Fizzy:

```
Auth:           app/controllers/concerns/authentication.rb
                app/models/identity.rb, magic_link.rb, session.rb
Multi-tenancy:  config/initializers/tenanting/account_slug.rb
                config/initializers/multi_tenant.rb
Current state:  app/models/current.rb
Jobs:           config/initializers/active_job.rb
                app/jobs/application_job.rb
UUID PKs:       config/initializers/uuid_primary_keys.rb
Deployment:     config/deploy.yml, Dockerfile
Testing:        test/test_helper.rb
CI:             config/ci.rb, bin/ci
Style:          STYLE.md, AGENTS.md
```

## Checklist bij elke nieuwe Rails feature

1. Heeft Fizzy dit al geïmplementeerd? → Lees `~/code/fizzy/app/`
2. Welk patroon gebruikt Fizzy? → Volg exact hetzelfde patroon
3. Past de code in Fizzy's STYLE.md? → Zo niet, pas aan voor je commit
4. Gebruikt de feature ENV vars voor config? → Nooit hardcoden, altijd via Kamal secrets

## Template voor nieuwe projecten

```bash
rails new myapp -m ~/code/appfabriek-rails-template/template.rb
```

Template repository: `~/code/appfabriek-rails-template/`
Documentatie: `~/code/appfabriek-rails-template/RAILS_AGENTS.md`
