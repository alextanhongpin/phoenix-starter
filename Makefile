build:
	MIX_ENV=prod mix compile
	MIX_ENV=prod mix release

run:
	PORT=4000 _build/prod/rel/phoenix_starter/bin/phoenix_starter foreground

docker:
	@docker build -t alextanhongpin/phoenix .