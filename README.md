# Run all services

Use the root `docker-compose.yaml` for the whole application. Set `APP_ENV` in
the root `.env` file to `production` or `development`; if unset, it defaults to
`development`.

```sh
docker compose up --build
```

Set `APP_ENV=production` in `.env` before running the command to start the
production image. Any other intended mode should be set to `development`.