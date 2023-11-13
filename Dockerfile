FROM python:3.11

COPY pyproject.toml poetry.lock ./
RUN touch README.md # poetry install requires README.md to exist
COPY mybatch/ ./mybatch/

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install poetry && \
    poetry config virtualenvs.in-project true && \
    poetry install

ARG COMMIT_HASH
RUN echo $COMMIT_HASH > /commithash.txt

ENTRYPOINT ["poetry", "run", "python", "-m", "mybatch"]
