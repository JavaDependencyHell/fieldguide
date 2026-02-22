# Makefile for Dependency Hell Fieldguide

# Define variables for reuse
BUILD_DIR = build/book
US_BUILD_DIR = build/us-book
PDF_OUTPUT = $(BUILD_DIR)/Dependency-Hell.pdf
US_PDF_OUTPUT = $(US_BUILD_DIR)/Dependency-Hell.pdf
FINAL_PDF = $(BUILD_DIR)/book.pdf
US_FINAL_PDF = $(US_BUILD_DIR)/book.pdf
SAMPLE_PDF = $(BUILD_DIR)/sample.pdf
US_SAMPLE_PDF = $(US_BUILD_DIR)/sample.pdf
FRONT_IMAGE = book/content/front-image.pdf

.PHONY: all init utils book book-html book-pdf us-book sample us-sample verify verify-maven verify-gradle verify-sbt clean help check-quarto check-qpdf

# Default target
all: init book verify

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all            - Initialize, build book, and verify all demos (default)"
	@echo "  init           - Build utilities and install demo dependencies to local repo"
	@echo "  utils          - Build demo-utils"
	@echo "  book-html      - Render the Quarto book (HTML)"
	@echo "  book           - Render the Quarto book (PDF)"
	@echo "  us-book        - Render the Quarto book (US Half-Letter PDF)"
	@echo "  sample         - Generate a sample PDF from the book"
	@echo "  us-sample      - Generate a US Half-Letter sample PDF"
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

# Render the book (HTML and PDF) and apply post-processing
book: check-quarto check-qpdf
	@echo "Generating Book (HTML, PDF)..."
	quarto render --to html --to pdf --output-dir $(BUILD_DIR)
	@echo "Removing first blank page from PDF..."
	qpdf $(PDF_OUTPUT) --pages . 2-z -- $(PDF_OUTPUT).tmp && mv $(PDF_OUTPUT).tmp $(PDF_OUTPUT)
	@echo "Cleaning up intermediate files..."
	find -L demos -name "guide_files" -type d -exec rm -rf {} +
	@echo "Book generation complete. Output in $(BUILD_DIR)/"

book-html: check-quarto
	quarto render --to html --output-dir $(BUILD_DIR)

book-pdf: book

# Render the US book (PDF) and apply post-processing
us-book: check-quarto check-qpdf
	@echo "Generating US Half-Letter Book (PDF)..."
	quarto render --profile halfletter --to pdf --output-dir $(US_BUILD_DIR)
	@echo "Removing first blank page from PDF..."
	qpdf $(US_PDF_OUTPUT) --pages . 2-z -- $(US_PDF_OUTPUT).tmp && mv $(US_PDF_OUTPUT).tmp $(US_PDF_OUTPUT)
	@echo "Cleaning up intermediate files..."
	find -L demos -name "guide_files" -type d -exec rm -rf {} +
	@echo "US Book generation complete. Output in $(US_BUILD_DIR)/"

# Generate a sample PDF
sample: book
	@echo "Generating Sample PDF..."
	@if [ -f $(FINAL_PDF) ]; then \
		qpdf $(FINAL_PDF) --pages . 1,7,8-18,29-31,38-40,44-47,48,60-63,84-87,89-92 -- $(SAMPLE_PDF); \
		echo "Sample generation complete. Output in $(SAMPLE_PDF)"; \
	else \
		echo "Error: $(FINAL_PDF) not found. Run 'make book' first."; \
		exit 1; \
	fi

# Generate a US sample PDF
us-sample: us-book
	@echo "Generating US Half-Letter Sample PDF..."
	@if [ -f $(US_FINAL_PDF) ]; then \
		qpdf $(US_FINAL_PDF) --pages . 1,7,8-18,29-31,38-40,44-47,48,60-63,84-87,89-92 -- $(US_SAMPLE_PDF); \
		echo "US Sample generation complete. Output in $(US_SAMPLE_PDF)"; \
	else \
		echo "Error: $(US_FINAL_PDF) not found. Run 'make us-book' first."; \
		exit 1; \
	fi

# Helper to check for quarto
check-quarto:
	@command -v quarto >/dev/null 2>&1 || { echo >&2 "Quarto not found. Visit https://quarto.org/docs/get-started/"; exit 1; }

# Helper to check for qpdf
check-qpdf:
	@command -v qpdf >/dev/null 2>&1 || { echo >&2 "qpdf not found. Please install qpdf (e.g., brew install qpdf)."; exit 1; }

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