.PHONY: test-inactive test-active setup workstation

test-inactive:
	@echo "Checking if daily_workstation container is running..."
	@if docker ps --filter name=daily_workstation --format '{{.Names}}' | grep -q daily_workstation; then \
		echo "Container is running - try again when container is not running"; \
		exit 1; \
	else \
		echo "Container is not running - checking for local NPM and Go..."; \
		if command -v npm >/dev/null 2>&1; then \
			echo "ERROR: npm is available locally when container is not running"; \
			exit 1; \
		fi; \
		if command -v go >/dev/null 2>&1; then \
			echo "ERROR: go is available locally when container is not running"; \
			exit 1; \
		fi; \
		echo "Local NPM and Go are not available - test passes"; \
		exit 0; \
	fi

test-active:
	@echo "Launching daily_workstation container..."
	@docker-compose up -d
	@echo "Waiting for container to be ready..."
	@sleep 2
	@echo "Verifying container is running..."
	@if ! docker ps --filter name=daily_workstation --format '{{.Names}}' | grep -q daily_workstation; then \
		echo "ERROR: Container failed to start"; \
		exit 1; \
	fi
	@echo "Checking Go installation..."
	@if ! PATH="$$(pwd)/bin:$$PATH" go version >/dev/null 2>&1; then \
		echo "ERROR: go version command failed"; \
		exit 1; \
	fi
	@echo "Checking NPM installation..."
	@if ! PATH="$$(pwd)/bin:$$PATH" npm --version >/dev/null 2>&1; then \
		echo "ERROR: npm --version command failed"; \
		exit 1; \
	fi
	@echo "Container is active and both Go and NPM are accessible - test passes"

setup:
	@echo "Setting up workstation environment..."
	@chmod +x setup.sh
	@echo ""
	@echo "To activate the environment, run:"
	@echo "  source setup.sh"
	@echo ""
	@echo "Or add the following to your shell profile (~/.zshrc, ~/.bashrc, etc.):"
	@echo "  export PATH=\"$$(pwd)/bin:\$$PATH\""
	@echo ""
	@echo "After sourcing, 'go' and 'npm' commands will use the container (when running)."

workstation:
	@echo "Starting workstation container..."
	@docker-compose up -d
	@echo "Workstation container started. Use 'make test-active' to verify it's working."
