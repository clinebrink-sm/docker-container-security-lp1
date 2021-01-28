default: deploy

static: Dockerfile
	@docker run --rm -i hadolint/hadolint hadolint --ignore DL3018 - < Dockerfile
	@echo "Running dockerfile_lint"
	@docker run -it --rm -v ${PWD}:/root/ projectatomic/dockerfile-lint dockerfile_lint -r policies/new_rules.yml

build: static
	@echo "Building Hugo Builder container..."
	@docker build -t lp/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images lp/hugo-builder

vulnscan:
	clair-scanner --ip 10.0.2.15 lp/hugo-builder

start: build vulnscan
	@echo "Starting Docker Instance"
	docker run -d --rm -i -p 1313:1313 --name hb lp/hugo-builder

deploy: start
	docker exec -d -w /src hb hugo new site orgdocs
	docker exec -d -w /src/orgdocs hb git init
	docker exec -d -w /src/orgdocs hb git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
	docker exec -d -w /src/orgdocs hb /bin/sh -c "echo 'theme = \"ananke\"' >> config.toml"
	docker exec -d -w /src/orgdocs hb hugo new posts/my-first-post.md
	sleep 5
	docker exec -d -w /src/orgdocs hb hugo server -w --bind=0.0.0.0

stop:
	docker stop hb
