# Python
FROM python:3.11 as builder

# Work
WORKDIR /app

COPY ./app-flask/app/requirements.txt ./
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

#FROM gcr.io/distroless/python3-debian12
FROM python:3.11-slim

COPY ./app-flask/ /
COPY --from=builder /usr/local/lib/python3.11/site-packages /root/.local/lib/python3.11/site-packages

ENTRYPOINT ["/usr/local/bin/python3", "/app-flask/app.py"]