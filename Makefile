# Makefile for Dependency Hell Fieldguide

.PHONY: all init utils book verify verify-maven verify-gradle verify-sbt clean help

# Default target
all: init book verify

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all            - Initialize, build book, and verify all demos (default)"
	@echo "  init           - Build utilities and install demo dependencies to local repo"
	@echo "  utils          - Build demo-utils"
	@echo "  book           - Render the Quarto book (HTML)"
	@echo "  book-pdf       - Render the Quarto book (PDF)"
	@echo "  verify         - Run all verification scripts"
	@echo "  verify-maven   - Run Maven-specific verification"
	@echo "  verify-gradle  - Run Gradle-specific verification"
	@echo "  verify-sbt     - Run SBT-specific verification"
	@echo "  clean          - Remove build artifacts"

# Initialize the project
init: utils
	./install_deps.sh

# Build the demo utilities
utils:
	cd demo-utils && mvn clean package -DskipTests

# Render the book
book:
	quarto render --to html

book-pdf:
	quarto render --to pdf

# Verification targets
verify: init
	./verify_all.sh

verify-maven: init
	cd demos/maven-demo && ./verify.sh

verify-gradle: init
	cd demos/gradle-demo && ./verify.sh

verify-sbt: init
	cd demos/sbt-demo && ./verify.sh

# Cleanup
clean:
	rm -rf target/
	rm -rf build/
	find . -type d -name ".gradle" -exec rm -rf {} +
	find . -type d -name "target" -not -path "./target*" -exec rm -rf {} +
	find . -type d -name "project/target" -exec rm -rf {} +
	find . -type d -name "project/project" -exec rm -rf {} +
	find . -type f -name "cp.txt" -delete
