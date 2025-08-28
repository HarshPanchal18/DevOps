# This is the first stage of a multi-stage build.
FROM golang:1.23 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app with CGO disabled and for Linux OS
RUN CGO_ENABLED=0 GOOS=linux go build -v -o main .

# Start a new stage from scratch
FROM alpine:latest

# Install necessary certificates
RUN apk --no-cache add ca-certificates

# Add a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Change ownership of the working directory
RUN chown appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"]