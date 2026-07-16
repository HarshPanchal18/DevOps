KUBECTL?=kubectl
# ARGS := $(filter-out init,$(MAKECMDGOALS))
# ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
# $(ARGS):
# 	@:
# Default namespace
# NS := $(if $(ARGS),$(ARGS),myproject)

NS=myproject
KAFKA_VERSION_TAG=0.45.0
KAFKA_REPO="strimzi/strimzi-kafka-operator"
# CRD_YAML_DIR="https://raw.githubusercontent.com/$(KAFKA_REPO)/refs/tags/$(KAFKA_VERSION_TAG)/install/cluster-operator"
CRD_YAML_DIR="https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator"

init:
	@if $(KUBECTL) get namespace $(NS) >/dev/null 2>&1; then \
		echo "Namespace '$(NS)' already exists. Skipping."; \
	else \
		echo "Creating namespace '$(NS)' ..."; \
		$(KUBECTL) create namespace $(NS); \
	fi

	@$(MAKE) prompt
	@echo \"make apply-crd\" to start installing Kafka

prompt:
	@echo Default variable values:
	@echo NS=$(NS)
	@echo KAFKA_REPO=$(KAFKA_REPO)
	@echo KAFKA_VERSION_TAG=$(KAFKA_VERSION_TAG)
	@echo CRD_YAML_DIR=$(CRD_YAML_DIR)

apply-crd: init
	@$(KUBECTL) apply -n $(NS) \
        -f $(CRD_YAML_DIR)/010-ServiceAccount-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/020-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/020-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/021-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/021-ClusterRoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/022-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/022-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/023-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/023-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/030-ClusterRole-strimzi-kafka-broker.yaml \
        -f $(CRD_YAML_DIR)/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml \
        -f $(CRD_YAML_DIR)/031-ClusterRole-strimzi-entity-operator.yaml \
        -f $(CRD_YAML_DIR)/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml \
        -f $(CRD_YAML_DIR)/033-ClusterRole-strimzi-kafka-client.yaml \
        -f $(CRD_YAML_DIR)/033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation.yaml \
        -f $(CRD_YAML_DIR)/040-Crd-kafka.yaml \
        -f $(CRD_YAML_DIR)/041-Crd-kafkaconnect.yaml \
        -f $(CRD_YAML_DIR)/042-Crd-strimzipodset.yaml \
        -f $(CRD_YAML_DIR)/043-Crd-kafkatopic.yaml \
        -f $(CRD_YAML_DIR)/044-Crd-kafkauser.yaml \
        -f $(CRD_YAML_DIR)/045-Crd-kafkamirrormaker.yaml \
        -f $(CRD_YAML_DIR)/046-Crd-kafkabridge.yaml \
        -f $(CRD_YAML_DIR)/047-Crd-kafkaconnector.yaml \
        -f $(CRD_YAML_DIR)/048-Crd-kafkamirrormaker2.yaml \
        -f $(CRD_YAML_DIR)/049-Crd-kafkarebalance.yaml \
        -f $(CRD_YAML_DIR)/04A-Crd-kafkanodepool.yaml \
        -f $(CRD_YAML_DIR)/050-ConfigMap-strimzi-cluster-operator.yaml
# \        -f $(CRD_YAML_DIR)/060-Deployment-strimzi-cluster-operator.yaml
#         kubectl apply -n myproject -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/refs/tags/0.45.0/install/cluster-operator/060-Deployment-strimzi-cluster-operator.yaml

# 	@$(KUBECTL) set env deployment/strimzi-cluster-operator -n $(NS) STRIMZI_KUBERNETES_VERSION="major=1,minor=33"
# 	@echo Review and adjust PV configurations before make deploy

install:
	@$(KUBECTL) apply-f $(CRD_YAML_DIR)/060-Deployment-strimzi-cluster-operator.yaml
	@$(KUBECTL) set env deployment/strimzi-cluster-operator -n $(NS) STRIMZI_KUBERNETES_VERSION="major=1,minor=33"
# 	kubectl set env deployment/strimzi-cluster-operator -n myproject STRIMZI_KUBERNETES_VERSION="major=1,minor=33"
	@$(KUBECTL) apply -f pv.yml
	@$(KUBECTL) apply -f kafka.yml

delete-strimzi:
	@$(KUBECTL) -n $(NS) delete deploy strimzi-cluster-operator --ignore-not-found=true

delete-crd: delete
	@$(KUBECTL) delete --ignore-not-found=true \
        -f $(CRD_YAML_DIR)/010-ServiceAccount-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/020-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/020-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/021-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/021-ClusterRoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/022-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/022-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/023-ClusterRole-strimzi-cluster-operator-role.yaml \
        -f $(CRD_YAML_DIR)/023-RoleBinding-strimzi-cluster-operator.yaml \
        -f $(CRD_YAML_DIR)/030-ClusterRole-strimzi-kafka-broker.yaml \
        -f $(CRD_YAML_DIR)/030-ClusterRoleBinding-strimzi-cluster-operator-kafka-broker-delegation.yaml \
        -f $(CRD_YAML_DIR)/031-ClusterRole-strimzi-entity-operator.yaml \
        -f $(CRD_YAML_DIR)/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml \
        -f $(CRD_YAML_DIR)/033-ClusterRole-strimzi-kafka-client.yaml \
        -f $(CRD_YAML_DIR)/033-ClusterRoleBinding-strimzi-cluster-operator-kafka-client-delegation.yaml \
        -f $(CRD_YAML_DIR)/040-Crd-kafka.yaml \
        -f $(CRD_YAML_DIR)/041-Crd-kafkaconnect.yaml \
        -f $(CRD_YAML_DIR)/042-Crd-strimzipodset.yaml \
        -f $(CRD_YAML_DIR)/043-Crd-kafkatopic.yaml \
        -f $(CRD_YAML_DIR)/044-Crd-kafkauser.yaml \
        -f $(CRD_YAML_DIR)/045-Crd-kafkamirrormaker.yaml \
        -f $(CRD_YAML_DIR)/046-Crd-kafkabridge.yaml \
        -f $(CRD_YAML_DIR)/047-Crd-kafkaconnector.yaml \
        -f $(CRD_YAML_DIR)/048-Crd-kafkamirrormaker2.yaml \
        -f $(CRD_YAML_DIR)/049-Crd-kafkarebalance.yaml \
        -f $(CRD_YAML_DIR)/04A-Crd-kafkanodepool.yaml \
#         -f $(CRD_YAML_DIR)/050-ConfigMap-strimzi-cluster-operator.yaml
#         \ -f $(CRD_YAML_DIR)/060-Deployment-strimzi-cluster-operator.yaml

delete:
	@$(KUBECTL) delete -f kafka.yml --ignore-not-found=true
	@$(KUBECTL) delete pvc -n $(NS) -l strimzi.io/cluster=kafka-data-kafka --ignore-not-found=true
	@$(KUBECTL) delete pvc -n $(NS) -l strimzi.io/cluster=kafka-data-zookeeper --ignore-not-found=true
	@$(KUBECTL) delete -f pv.yml --ignore-not-found=true
# 	@$(MAKE) delete-crd
# 	@$(KUBECTL) delete deploy -n $(NS) strimzi-cluster-operator --ignore-not-found=true

clean:
	@$(KUBECTL) delete ns $(NS) --ignore-not-found=true