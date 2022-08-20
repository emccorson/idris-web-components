build: CustomElement.idr
	idris2 --codegen javascript -o out.js --output-dir Example/public Example.idr
	cp CustomElement/helper.js Example/public

dev:
	idris2 CustomElement.idr

clean:
	rm -rf build
	find . -type f -name '*.idr~' -delete
