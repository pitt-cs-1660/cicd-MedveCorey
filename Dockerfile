# Builder Stage
FROM python:3.11-buster AS builder

# Set the working directory
WORKDIR /app

# Upgrade pip and install Poetry
RUN pip install --upgrade pip && pip install poetry

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install dependencies without creating a virtual environment
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Application Stage
FROM python:3.11-buster AS app

# Set the working directory
WORKDIR /app

# Copy application code from the builder stage
COPY --from=builder /app /app

# Expose port 8000 for FastAPI
EXPOSE 8000

# Copy the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Set the entrypoint for the container
ENTRYPOINT ["sh", "/app/entrypoint.sh"]

# Command to run the FastAPI application
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
