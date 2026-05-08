VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS  = -s -w -X main.Version=$(VERSION)

.PHONY: build test lint clean

build:
	go build -ldflags="$(LDFLAGS)" -o bin/ocgo2cli .

test:
	go test -race ./...

lint:
	go vet ./...

clean:
	rm -rf bin/
