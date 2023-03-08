FROM python:3.10-slim-buster

# ARG POSTGRES_SERVER

ENV API_V1_PREFIX="/api/v1" \
  DEBUG=True \
  PROJECT_NAME="Heroes App (local)" \
  VERSION="0.1.0" \
  DESCRIPTION="The API for Heroes app." \
  POSTGRES_USERNAME="postgres" \
  POSTGRES_PASSWORD="thepass123" \
  POSTGRES_SERVER='172.17.0.2' \
  POSTGRES_POART="5432" \
  POSTGRES_DATABASE="postgres" \
  POSTGRES_TEST_DATABASE="postgres-test" \
  DB_ASYNC_CONNECTION_STR=postgresql+asyncpg://${POSTGRES_USERNAME}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}:${POSTGRES_POART}/${POSTGRES_DATABASE} \
  DB_ASYNC_TEST_CONNECTION_STR=postgresql+asyncpg://${POSTGRES_USERNAME}:${POSTGRES_PASSWORD}@${POSTGRES_SERVER}:${POSTGRES_POART}/${POSTGRES_TEST_DATABASE} \
  DB_EXCLUDE_TABLES="[]" \
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VERSION=1.1.13

# System deps:
RUN pip install "poetry==$POETRY_VERSION"

# Copy only requirements to cache them in docker layer
WORKDIR /vyce-backend
COPY poetry.lock pyproject.toml /vyce-backend/


# Project initialization:
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi

# Creating folders, and files for a project:
COPY . /vyce-backend

# RUN touch .env
# RUN bash docker-env-entrypoint

RUN alembic upgrade head

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
