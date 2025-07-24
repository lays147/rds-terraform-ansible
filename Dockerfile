FROM python:3.13-alpine AS builder

# RUN apt-get -y update && apt-get -y upgrade && apt-get install -y --no-install-recommends
RUN apk add --no-cache \
  build-base \
  libpq-dev

# hadolint ignore=DL3042
RUN pip install poetry==2.1.3

ENV POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_IN_PROJECT=1 \
  POETRY_VIRTUALENVS_CREATE=1 \
  POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY ./ansible/pyproject.toml ./ansible/poetry.lock ./

RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --no-root

FROM python:3.13-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache libpq

ENV VIRTUAL_ENV=/app/.venv 
ENV PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./ansible/playbook.yml ./playbook.yml

ENTRYPOINT ["ansible-playbook","-i","localhost","playbook.yml"]
