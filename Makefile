# note: PROJECT_IDは環境変数から取得する
# note: gcloud auth configure-docker asia-northeast1-docker.pkg.dev を実行しておく必要がある(1回だけで良い)


GCP_REGION := asia-northeast1
SERVICE_NAME := hotoku-batch
JOB_ID := example-container-job-$(shell date +%Y%m%d%H%M%S)


REPO_NAME := $(SERVICE_NAME)
IMAGE_NAME := $(SERVICE_NAME)
IMAGE_PATH = $(GCP_REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO_NAME)/$(IMAGE_NAME)


.PHONY: submit
submit:
	gcloud batch jobs submit $(JOB_ID) \
		--location $(GCP_REGION) \
		--config mybatch.json \
		--substitutions=_IMAGE_PATH=$(IMAGE_PATH):$(IMAGE_TAG)


.PHONY: push
push: image
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_PATH):$(IMAGE_TAG)
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_PATH):latest
	docker push $(IMAGE_PATH):$(IMAGE_TAG)
	docker push $(IMAGE_PATH):latest


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
