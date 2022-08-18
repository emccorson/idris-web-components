build: CustomElement.idr
	idris2 --codegen javascript -o out.js --output-dir . Example.idr

dev:
	idris2 CustomElement.idr

clean:
	rm -rf build *.idr~
