# note: PROJECT_IDは環境変数から取得する
# note: gcloud auth configure-docker asia-northeast1-docker.pkg.dev を実行しておく必要がある(1回だけで良い)


GCP_REGION := asia-northeast1
JOB_ID := example-container-job-$(shell date +%Y%m%d%H%M%S)
SERVICE_NAME := hotoku-batch
REPO_NAME := hotoku-batch
IMAGE_NAME := hotoku-batch


IMAGE_PATH = $(GCP_REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO_NAME)/$(IMAGE_NAME)


.PHONY: submit
submit:
	gcloud batch jobs submit $(JOB_ID) \
		--location $(GCP_REGION) \
		--config mybatch.json


.PHONY: push
push: image create-repository
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_PATH):$(IMAGE_TAG)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_PATH):latest
	docker push $(IMAGE_PATH):$(IMAGE_TAG)
	docker push $(IMAGE_PATH):latest


.PHONY: create-repository
create-repository:
	if ! gcloud artifacts repositories describe --location=$(GCP_REGION) $(REPO_NAME) > /dev/null 2>&1; then \
		gcloud artifacts repositories create $(REPO_NAME) \
			--repository-format=docker \
			--location=$(GCP_REGION) \
			--description="Repository for $(IMAGE_NAME) images."; \
	fi


.PHONY: image
image: image-tag
	docker build \
		--build-arg COMMIT_HASH=$(shell git rev-parse HEAD) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) .


.PHONY: image-tag
image-tag: tree-clean
	$(eval IMAGE_TAG := $(shell git rev-parse HEAD | fold -w7 | head -n1))


.PHONY: tree-clean
tree-clean:
	@if [ $$(git status -s | wc -l) -ge 1 ]; then echo "Error: local tree is dirty."; false; fi
