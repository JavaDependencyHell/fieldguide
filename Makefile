# Makefile for Dependency Hell Fieldguide

# Define variables for reuse
BUILD_DIR = build/book
US_BUILD_DIR = build/us-book
PDF_OUTPUT = $(BUILD_DIR)/Dependency-Hell.pdf
US_PDF_OUTPUT = $(US_BUILD_DIR)/Dependency-Hell.pdf
FINAL_PDF = $(BUILD_DIR)/book.pdf
US_FINAL_PDF = $(US_BUILD_DIR)/Dependency-Hell.pdf
SAMPLE_PDF = $(BUILD_DIR)/sample.pdf
US_SAMPLE_PDF = $(US_BUILD_DIR)/sample.pdf
BROCHURE_PDF = $(BUILD_DIR)/brochure.pdf
US_BROCHURE_PDF = $(US_BUILD_DIR)/brochure.pdf
FRONT_IMAGE = book/content/front-image.pdf

.PHONY: all init utils init-python book book-html book-pdf us-book herodevs-site sample us-sample brochure us-brochure verify verify-maven verify-gradle verify-sbt verify-python clean help check-quarto check-qpdf force-book force-us-book

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
	@echo "  brochure       - Generate a brochure PDF from the book"
	@echo "  us-sample      - Generate a US Half-Letter sample PDF"
	@echo "  us-brochure    - Generate a US Half-Letter brochure PDF"
	@echo "  verify         - Run all verification scripts"
	@echo "  verify-maven   - Run Maven-specific verification"
	@echo "  verify-gradle  - Run Gradle-specific verification"
	@echo "  verify-sbt     - Run SBT-specific verification"
	@echo "  verify-python  - Run Python-specific verification"
	@echo "  init-python    - Build Python demo packages into local wheel repo"
	@echo "  herodevs-site  - Build HeroDevs-branded HTML site for fieldguide.herodevs.com"
	@echo "  clean          - Remove build artifacts"

# Initialize the project
init: utils init-python
	./install_deps.sh

# Build Python demo packages into local wheel repo
init-python:
	./install_python_deps.sh

# Build the demo utilities
utils:
	cd demo-utils && mvn clean package -DskipTests

# Render the book (HTML and PDF) and apply post-processing
book: $(PDF_OUTPUT)

$(PDF_OUTPUT):
	@$(MAKE) force-book

force-book: check-quarto check-qpdf
	@echo "Generating Book (HTML, PDF)..."
	quarto render --to html --to pdf --output-dir $(BUILD_DIR)
	@echo "Removing first blank page from PDF..."
	qpdf $(PDF_OUTPUT) --pages . 2-z -- $(PDF_OUTPUT).tmp && mv $(PDF_OUTPUT).tmp $(PDF_OUTPUT)
	@echo "Cleaning up intermediate files..."
	find -L demos -name "guide_files" -type d -exec rm -rf {} +
	@echo "Book generation complete. Output in $(BUILD_DIR)/"

book-html: check-quarto
	quarto render --to html --output-dir $(BUILD_DIR)

# Render HeroDevs-branded HTML site
herodevs-site: check-quarto
	@echo "Generating HeroDevs-branded site..."
	quarto render --profile herodevs --to html
	@echo "HeroDevs site generated in build/herodevs-site/"

book-pdf: book

# Render the US book (PDF) and apply post-processing
us-book: $(US_PDF_OUTPUT)

$(US_PDF_OUTPUT):
	@$(MAKE) force-us-book

force-us-book: check-quarto check-qpdf
	@echo "Generating US Half-Letter Book (PDF)..."
	quarto render --profile halfletter --to pdf --output-dir $(US_BUILD_DIR)
	@echo "Removing first blank page from PDF..."
	qpdf $(US_PDF_OUTPUT) --pages . 2-z -- $(US_PDF_OUTPUT).tmp && mv $(US_PDF_OUTPUT).tmp $(US_PDF_OUTPUT)
	@echo "Cleaning up intermediate files..."
	find -L demos -name "guide_files" -type d -exec rm -rf {} +
	@echo "US Book generation complete. Output in $(US_BUILD_DIR)/"

# Generate a sample PDF
sample: $(PDF_OUTPUT)
	@echo "Generating Sample PDF..."
	@if [ -f $(PDF_OUTPUT) ]; then \
		qpdf $(PDF_OUTPUT) --pages . 1-10,12-32,36-37,40-42,47-57,60-62 -- $(SAMPLE_PDF); \
		echo "Sample generation complete. Output in $(SAMPLE_PDF)"; \
	else \
		echo "Error: $(PDF_OUTPUT) not found. Run 'make book' first."; \
		exit 1; \
	fi

# Generate a US sample PDF
us-sample: $(US_PDF_OUTPUT)
	@echo "Generating US Half-Letter Sample PDF..."
	@if [ -f $(US_PDF_OUTPUT) ]; then \
		qpdf $(US_PDF_OUTPUT) --pages . 1-9,12-13,14-22,33-34,39-41,53-56,57,60-62,69-70,95-98,99-106,z -- $(US_SAMPLE_PDF); \
		echo "US Sample generation complete. Output in $(US_SAMPLE_PDF)"; \
	else \
		echo "Error: $(US_PDF_OUTPUT) not found. Run 'make us-book' first."; \
		exit 1; \
	fi

# Generate a brochure PDF (same selection as sample)
brochure: $(PDF_OUTPUT)
	@echo "Generating Brochure PDF..."
	@if [ -f $(PDF_OUTPUT) ]; then \
		qpdf $(PDF_OUTPUT) --pages . 1,2,4,5,10,3,15-17,18-20,24-26,56,57,58,59,z -- $(BROCHURE_PDF); \
		echo "Brochure generation complete. Output in $(BROCHURE_PDF)"; \
	else \
		echo "Error: $(PDF_OUTPUT) not found. Run 'make book' first."; \
		exit 1; \
	fi

# Generate a US brochure PDF (same selection as US sample)
us-brochure: $(US_PDF_OUTPUT)
	@echo "Generating US Half-Letter Brochure PDF..."
	@if [ -f $(US_PDF_OUTPUT) ]; then \
		qpdf $(US_PDF_OUTPUT) --pages . 1,2,4,5,10,3,15-17,18-20,24-26,56,57,58,59,z  -- $(US_BROCHURE_PDF); \
		echo "US Brochure generation complete. Output in $(US_BROCHURE_PDF)"; \
	else \
		echo "Error: $(US_PDF_OUTPUT) not found. Run 'make us-book' first."; \
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

verify-python: init-python
	cd demos/python-demo && bash verify.sh

# Cleanup
clean:
	rm -rf target/
	rm -rf build/
	find . -type d -name ".gradle" -exec rm -rf {} +
	find . -type d -name "target" -not -path "./target*" -exec rm -rf {} +
	find . -type d -name "project/target" -exec rm -rf {} +
	find . -type d -name "project/project" -exec rm -rf {} +
	find . -type f -name "cp.txt" -delete