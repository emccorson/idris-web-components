build: CustomElement.idr
	idris2 --codegen javascript -o out.js CustomElement.idr

dev:
	idris2 CustomElement.idr
