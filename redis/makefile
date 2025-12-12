KUBECTL ?= kubectl

all: deploy

create:
	@$(KUBECTL) apply -n default -f cm-redis-config.yml

deploy:
	@$(KUBECTL) create ns default
	@$(KUBECTL) apply -f cm-redis-config.yml -n redis
	@$(KUBECTL) apply -f sts-svc-redis.yml -n redis
	@$(KUBECTL) apply -f sts-svc-sentinel.yml -n redis
	$(info "Redis is deployed...")
	@$(KUBECTL) get pods -n redis

clean:
	@$(KUBECTL) delete -f cm-redis-config.yml -n redis
	@$(KUBECTL) delete -f sts-svc-redis.yml -n redis
	@$(KUBECTL) delete -f sts-svc-sentinel.yml -n redis
	@$(info "Redis is cleaned up. Delete 'redis' namespace. make delete")

delete:
	@$(KUBECTL) delete ns redis